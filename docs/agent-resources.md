# Agent resource limits

`agent-heavy` admits two checks or builds across all sessions. Each job runs in
its own systemd service. The parent `agent-work.slice` limits their combined RAM
to 12 GiB before reclaim throttling and 14 GiB before OOM, with 2 GiB of swap.

| Job | MemoryHigh | MemoryMax | Swap maximum | CPUs |
| --- | --- | --- | --- | --- |
| Default | 4 GiB | 6 GiB | 1 GiB | Half the available logical CPUs |
| `--light` | 1 GiB | 2 GiB | 1 GiB | Half the available logical CPUs |
| `--exclusive` | 8 GiB | 12 GiB | 1 GiB | All available CPUs |

`--light --exclusive` gives a small job exclusive access. Exclusive jobs reserve
both slots. Jobs have a two-hour runtime limit. Nested heavy runners fail;
run a coupled server and client inside the same invocation.

Admission requires the job's soft limit plus 1 GiB of available memory, after
subtracting the unused soft-limit reservations of running jobs. It also requires
system memory PSI `some avg10` below 2%. Waiting is cancellable. MemoryHigh
causes reclaim and slowdown; MemoryMax can kill the job. These limits protect
host responsiveness, rather than guaranteeing that an oversized build succeeds.

```sh
~/scripts/agent-heavy uv run ty check --error-on-warning
~/scripts/agent-heavy --light uv run ruff check .
~/scripts/agent-heavy --exclusive ./gradlew --no-daemon assembleDebug
```

Services are named `agent-heavy-slot-1.service` and `agent-heavy-slot-2.service`.
A live service keeps its slot occupied even if its supervisor is killed.
Normal completion and cancellation stop remaining children. ExecStopPost records
peak memory, peak swap, OOM kills and service result in
`~/.local/state/agent-heavy/jobs.tsv`, then removes containers labelled for that
job. Job identifiers contain no command arguments or credentials.

## Agent sessions

Kiln and Linux shell aliases launch new coding sessions through `agent-session`.
Each scope has a 3 GiB soft limit, 6 GiB hard limit and 512 MiB swap limit. The
shared `agent-sessions.slice` has 8 GiB soft and 10 GiB hard limits. Sessions and
heavy jobs share `agent.slice`, capped at 12 GiB soft, 16 GiB hard and 3 GiB swap.
Heavy jobs launch in a sibling service, outside the individual session limit.
Existing sessions retain their current cgroups. Reload shell aliases with
`source ~/.zshalias`; kiln uses the updated commands for new sessions.

Persistent development servers belong outside the job and session scopes:

```sh
systemd-run --user --unit=my-task-dev --same-dir --slice=app.slice \
  --property=KillMode=control-group /absolute/path/to/server
systemctl --user stop my-task-dev.service
```

Use an explicit environment configuration for that service, as systemd services
do not inherit the shell environment automatically. Stop only the unit you own.

## Containers

Rootful Docker containers do not inherit the client process's cgroup. The system
`agent-containers.slice` supplies an aggregate 4 GiB soft limit, 6 GiB hard limit
and 2 GiB swap limit. `agent-container` runs only inside a heavy job, sets this
parent, caps each container at 2 GiB RAM plus 1 GiB swap and four CPUs, and labels
it with the job identifier. Detached containers are removed when the job ends.

```sh
~/scripts/agent-heavy --light bash -c '
  ~/scripts/agent-container -d -p 15432:5432 -e POSTGRES_PASSWORD=test \
    -- pgvector/pgvector:pg17
  ./check-local-stack
'
```

For SDK-created containers, set `cgroup_parent="agent-containers.slice"`,
`mem_limit="2g"`, `memswap_limit="3g"`, and
`labels={"agent-heavy.unit": os.environ["AGENT_HEAVY_UNIT"]}`. Compose uses
`cgroup_parent`, `mem_limit`, `memswap_limit` and the same label. An SDK that
cannot set these must use direct processes or explicitly manage its own bounded
containers. A plain `docker run` has none of these guarantees.

## Installation and status

Dotter deploys the scripts, user slices and kiln configuration. Its root package
deploys the container slice. After deployment:

```sh
systemctl --user daemon-reload
sudo systemctl daemon-reload
sudo systemctl enable --now agent-containers.slice
systemctl --user list-units 'agent*'
systemctl show agent-containers.slice -p MemoryCurrent -p MemoryMax
systemd-cgtop
cat /proc/pressure/memory
tail ~/.local/state/agent-heavy/jobs.tsv
```

Run `python tests/test_agent_resources.py` on an idle workstation to verify real
systemd admission, parallelism, exclusive access, exit codes and cleanup. The
checks use tiny processes and isolated lock files, and refuse to run while the
new heavy-job services are occupied. Old single-lock jobs finish normally before
new production jobs are admitted.
