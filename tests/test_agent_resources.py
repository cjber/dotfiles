"""Live workstation checks: requires idle agent-heavy slots and systemd user bus."""

import os
import subprocess
import tempfile
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "scripts/agent-heavy"
SESSION = ROOT / "scripts/agent-session"
GATE = """
import pathlib, subprocess, sys, time
base = pathlib.Path(sys.argv[1])
child = subprocess.Popen(['sleep', '60'])
base.with_suffix('.pid').write_text(str(child.pid))
base.with_suffix('.started').touch()
while not base.with_suffix('.release').exists(): time.sleep(.05)
child.terminate()
child.wait()
"""


class ResourceChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(
            prefix="agent-resource-check-", dir=f"/run/user/{os.getuid()}"
        )
        cls.directory = Path(cls.temp.name)
        for name in ("systemd", "bus"):
            (cls.directory / name).symlink_to(f"/run/user/{os.getuid()}/{name}")
        cls.env = os.environ | {
            "XDG_RUNTIME_DIR": cls.temp.name,
            "XDG_STATE_HOME": cls.temp.name,
            "DBUS_SESSION_BUS_ADDRESS": f"unix:path=/run/user/{os.getuid()}/bus",
        }
        cls.env.pop("AGENT_HEAVY_ACTIVE", None)
        cls.env.pop("AGENT_SESSION_ACTIVE", None)
        for slot in (1, 2):
            state = subprocess.check_output(
                [
                    "systemctl",
                    "--user",
                    "show",
                    f"agent-heavy-slot-{slot}.service",
                    "-p",
                    "ActiveState",
                    "--value",
                ],
                env=cls.env,
                text=True,
            ).strip()
            if state not in ("inactive", "failed", ""):
                cls.temp.cleanup()
                raise RuntimeError("Heavy-job slots must be idle before running these checks")

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def setUp(self):
        self.jobs = []
        self.bases = []

    def tearDown(self):
        for base in self.bases:
            base.with_suffix(".release").touch()
        for job in self.jobs:
            if job.poll() is None:
                job.terminate()
            try:
                job.communicate(timeout=15)
            except subprocess.TimeoutExpired:
                job.kill()
                job.communicate(timeout=15)

    def wait_for(self, predicate, seconds=60):
        deadline = time.monotonic() + seconds
        while not predicate():
            if time.monotonic() >= deadline:
                self.fail("Timed out waiting for real resource-runner behavior")
            time.sleep(0.05)

    def start(self, name, exclusive=False):
        base = self.directory / name
        self.bases.append(base)
        args = [str(RUNNER), "--light"]
        if exclusive:
            args.append("--exclusive")
        job = subprocess.Popen(
            args + ["/usr/bin/python", "-c", GATE, str(base)],
            env=self.env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            start_new_session=True,
        )
        self.jobs.append(job)
        return job, base

    def started(self, base):
        self.wait_for(lambda: base.with_suffix(".started").exists())

    def release(self, job, base):
        base.with_suffix(".release").touch()
        output = job.communicate(timeout=15)
        self.assertEqual(job.returncode, 0, output)

    def test_parallel_slots_and_waiter_cancellation(self):
        one, a = self.start("parallel-a")
        two, b = self.start("parallel-b")
        self.started(a)
        self.started(b)
        three, c = self.start("parallel-c")
        time.sleep(0.5)
        self.assertFalse(c.with_suffix(".started").exists())
        three.terminate()
        three.communicate(timeout=5)
        self.assertEqual(three.returncode, 143)
        self.release(one, a)
        self.release(two, b)

    def test_exclusive_blocks_both_slots(self):
        one, a = self.start("exclusive-a")
        two, b = self.start("exclusive-b")
        self.started(a)
        self.started(b)
        exclusive, c = self.start("exclusive-c", exclusive=True)
        time.sleep(0.5)
        self.assertFalse(c.with_suffix(".started").exists())
        self.release(one, a)
        time.sleep(0.5)
        self.assertFalse(c.with_suffix(".started").exists())
        self.release(two, b)
        self.started(c)
        next_job, d = self.start("exclusive-d")
        time.sleep(0.5)
        self.assertFalse(d.with_suffix(".started").exists())
        self.release(exclusive, c)
        self.started(d)
        self.release(next_job, d)

    def test_running_cancellation_reaps_children(self):
        job, base = self.start("cancel-running")
        self.started(base)
        pid = int(base.with_suffix(".pid").read_text())
        job.terminate()
        job.communicate(timeout=15)
        self.assertEqual(job.returncode, 143)
        self.wait_for(lambda: not Path(f"/proc/{pid}").exists())

    def test_killed_supervisor_does_not_free_live_slot(self):
        one, a = self.start("orphan-a")
        two, b = self.start("orphan-b")
        self.started(a)
        self.started(b)
        one.kill()
        one.wait(timeout=5)
        three, c = self.start("orphan-c")
        time.sleep(0.5)
        self.assertFalse(c.with_suffix(".started").exists())
        a.with_suffix(".release").touch()
        one.communicate(timeout=15)
        self.started(c)
        self.release(two, b)
        self.release(three, c)

    def test_container_limits_and_cleanup(self):
        image = "pgvector/pgvector:pg17"
        found = subprocess.run(
            ["docker", "image", "inspect", image], check=False, capture_output=True
        )
        if found.returncode:
            self.skipTest("Requires an existing pgvector:pg17 image, never pulls images")
        identifier = self.directory / "container.id"
        ready = self.directory / "container.ready"
        script = (
            '"$HOME/scripts/agent-container" -d --entrypoint /bin/sh -- '
            'pgvector/pgvector:pg17 -c "sleep 60" > "$1"; touch "$2"; sleep 60'
        )
        job = subprocess.Popen(
            [
                str(RUNNER),
                "--light",
                "bash",
                "-e",
                "-c",
                script,
                "_",
                str(identifier),
                str(ready),
            ],
            env=self.env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            start_new_session=True,
        )
        self.jobs.append(job)
        self.wait_for(ready.exists)
        container = identifier.read_text().strip()
        self.addCleanup(
            lambda: subprocess.run(
                ["docker", "rm", "-f", container], check=False, capture_output=True
            )
        )
        limits = subprocess.check_output(
            [
                "docker",
                "inspect",
                "--format",
                "{{.HostConfig.CgroupParent}} {{.HostConfig.Memory}} {{.HostConfig.MemorySwap}}",
                container,
            ],
            text=True,
        ).strip()
        self.assertEqual(limits, "agent-containers.slice 2147483648 3221225472")
        job.terminate()
        job.communicate(timeout=15)
        self.assertEqual(job.returncode, 143)
        remaining = subprocess.run(
            ["docker", "inspect", container], check=False, capture_output=True
        )
        self.assertNotEqual(remaining.returncode, 0)

    def test_stdin_exit_status_nesting_and_session(self):
        result = subprocess.run(
            [
                str(RUNNER),
                "--light",
                "bash",
                "-c",
                'read -r value; echo "$value"; exit 7',
            ],
            input="stdin-proof\n",
            env=self.env,
            check=False,
            capture_output=True,
            text=True,
            timeout=60,
        )
        self.assertEqual(result.returncode, 7, result.stderr)
        self.assertIn("stdin-proof", result.stdout)
        result = subprocess.run(
            [
                str(RUNNER),
                "--light",
                "env",
                "-u",
                "AGENT_HEAVY_ACTIVE",
                str(RUNNER),
                "true",
            ],
            env=self.env,
            check=False,
            capture_output=True,
            text=True,
            timeout=60,
        )
        self.assertEqual(result.returncode, 2, result.stderr)
        result = subprocess.run(
            [str(SESSION), "bash", "-c", "cat /proc/self/cgroup; exit 3"],
            env=self.env,
            check=False,
            capture_output=True,
            text=True,
            timeout=15,
        )
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertIn("/agent-sessions.slice/", result.stdout)
        records = (self.directory / "agent-heavy/jobs.tsv").read_text().splitlines()
        self.assertTrue(records)
        self.assertTrue(all(int(row.split("\t")[2]) > 0 for row in records))


if __name__ == "__main__":
    unittest.main(verbosity=2)
