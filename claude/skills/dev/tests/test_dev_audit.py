import importlib.util
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "scripts" / "dev-audit"
SPEC = importlib.util.spec_from_loader(
    "dev_audit", SourceFileLoader("dev_audit", str(SCRIPT))
)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


def snapshot(
    name: str, base: str, head: str, *, checkout: str | None = None, dirty: bool = False
):
    return MODULE.RepositorySnapshot(
        repo=name,
        path=f"/tmp/{name}",
        base_sha=base,
        tested_sha=head,
        checkout_sha=checkout or head,
        dirty=dirty,
    )


def test_composition_digest_is_order_independent() -> None:
    first = snapshot("nebula", "a" * 40, "b" * 40)
    second = snapshot("nebula-web", "c" * 40, "d" * 40)

    assert MODULE.composition_digest([first, second]) == MODULE.composition_digest(
        [second, first]
    )


def test_any_sha_change_invalidates_composition() -> None:
    before = snapshot("nebula", "a" * 40, "b" * 40)
    after = snapshot("nebula", "a" * 40, "c" * 40)

    assert MODULE.composition_digest([before]) != MODULE.composition_digest([after])


def test_aggregate_fails_closed() -> None:
    assert (
        MODULE.aggregate_verdict([{"verdict": "pass"}, {"verdict": "incomplete"}])
        == "incomplete"
    )
    assert (
        MODULE.aggregate_verdict([{"verdict": "pass"}, {"verdict": "fail"}]) == "fail"
    )
    assert MODULE.aggregate_verdict([{"verdict": "pass"}, {}]) == "error"


def test_plan_requires_clean_exact_staging_checkouts(monkeypatch) -> None:
    changed = snapshot("nebula", "a" * 40, "b" * 40, checkout="c" * 40)
    monkeypatch.setattr(MODULE, "changed_files", lambda _snapshot: [])

    assert MODULE.build_plan([changed])["verdict"] == "incomplete"
    assert (
        MODULE.build_plan([snapshot("nebula", "a" * 40, "b" * 40, dirty=True)])[
            "verdict"
        ]
        == "incomplete"
    )


def test_dirty_plan_cannot_be_overridden_by_passing_adapters(
    monkeypatch, tmp_path
) -> None:
    plan = {"verdict": "incomplete", "repositories": []}

    assert MODULE.run_adapters(plan, tmp_path, full=False)["verdict"] == "incomplete"


def test_adapter_result_must_match_exact_composition() -> None:
    expected = {"repo": "nebula", "base_sha": "a" * 40, "tested_sha": "b" * 40}
    valid = {
        "schema_version": "1",
        "repository": "nebula",
        "base_sha": "a" * 40,
        "tested_sha": "b" * 40,
        "verdict": "pass",
    }

    assert MODULE.validate_adapter_result(valid, expected) is None
    assert MODULE.validate_adapter_result({**valid, "tested_sha": "c" * 40}, expected)


def test_markdown_report_contains_attestation_and_shas() -> None:
    report = {
        "verdict": "pass",
        "composition_digest": "digest",
        "created_at": "now",
        "repositories": [
            {
                "repo": "nebula",
                "base_sha": "a" * 40,
                "tested_sha": "b" * 40,
                "changed_file_count": 1,
                "dirty": False,
            }
        ],
    }
    rendered = MODULE.render_markdown(report)

    assert "Nebula composed staging audit" in rendered
    assert "`aaaaaaaaaaaa`" in rendered
    assert "fresh four-repository composition digest" in rendered


def test_stale_adapter_output_is_removed_and_failed_run_cannot_reuse_it(
    monkeypatch, tmp_path
) -> None:
    output = tmp_path / "nebula.json"
    output.write_text('{"verdict":"pass"}')
    repo_data = {
        "repo": "nebula",
        "path": str(tmp_path),
        "base_sha": "a" * 40,
        "tested_sha": "b" * 40,
    }
    monkeypatch.setattr(MODULE, "adapter_command", lambda *_args, **_kwargs: ["false"])

    report = MODULE.run_adapters(
        {"verdict": "pass", "repositories": [repo_data]}, tmp_path, full=False
    )

    assert report["verdict"] == "error"
    assert report["adapter_results"][0]["error"].endswith("without a report")


def test_adapter_timeout_becomes_formal_error_report(monkeypatch, tmp_path) -> None:
    repo_data = {
        "repo": "nebula",
        "path": str(tmp_path),
        "base_sha": "a" * 40,
        "tested_sha": "b" * 40,
    }

    def time_out(*_args, **_kwargs):
        raise MODULE.subprocess.TimeoutExpired(["adapter"], 3600)

    monkeypatch.setattr(MODULE.subprocess, "run", time_out)
    report = MODULE.run_adapters(
        {"verdict": "pass", "repositories": [repo_data]}, tmp_path, full=False
    )

    assert report["verdict"] == "error"
    assert report["adapter_results"] == [
        {
            "schema_version": "1",
            "repository": "nebula",
            "base_sha": "a" * 40,
            "tested_sha": "b" * 40,
            "verdict": "error",
            "error_kind": "timeout",
            "error": "adapter timed out after 3600 seconds",
        }
    ]


def test_adapter_launch_failure_becomes_formal_error_report(
    monkeypatch, tmp_path
) -> None:
    repo_data = {
        "repo": "nebula-web",
        "path": str(tmp_path),
        "base_sha": "a" * 40,
        "tested_sha": "b" * 40,
    }

    def fail_to_launch(*_args, **_kwargs):
        raise FileNotFoundError("pnpm")

    monkeypatch.setattr(MODULE.subprocess, "run", fail_to_launch)
    report = MODULE.run_adapters(
        {"verdict": "pass", "repositories": [repo_data]}, tmp_path, full=False
    )

    result = report["adapter_results"][0]
    assert report["verdict"] == "error"
    assert result["repository"] == "nebula-web"
    assert result["error_kind"] == "launch_error"
    assert result["error"] == "adapter could not be launched: pnpm"


def test_attestation_requires_exact_formal_four_repository_evidence() -> None:
    names = MODULE.REPOSITORIES
    snapshots = [
        snapshot(name, str(index) * 40, str(index + 4) * 40)
        for index, name in enumerate(names)
    ]
    repositories = [
        {
            **MODULE.asdict(item),
            "changed_files": [],
            "changed_file_count": 0,
        }
        for item in snapshots
    ]
    adapter_results = [
        {
            "schema_version": "1",
            "repository": item.repo,
            "base_sha": item.base_sha,
            "tested_sha": item.tested_sha,
            "verdict": "pass",
        }
        for item in snapshots
    ]
    valid = {
        "schema_version": "1",
        "kind": "dev_audit_report",
        "verdict": "pass",
        "composition_digest": MODULE.composition_digest(snapshots),
        "repositories": repositories,
        "adapter_results": adapter_results,
    }

    assert MODULE.validate_attestation_report(valid, snapshots) == []
    assert MODULE.validate_attestation_report(
        {"verdict": "pass", "composition_digest": valid["composition_digest"]},
        snapshots,
    )
    assert MODULE.validate_attestation_report(
        {**valid, "adapter_results": adapter_results[:-1]}, snapshots
    )
