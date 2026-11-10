"""Fail unless every job in a caller workflow feeds its merge gate.

    check_merge_gate.py <workflow file> <merge gate job id>

The merge gate is the single required status check. A job missing from its
`needs` can fail without turning the gate red.
"""

import sys

import yaml


def missing_from_gate(workflow: dict, gate: str) -> list[str]:
    jobs = workflow.get("jobs") or {}
    if gate not in jobs:
        raise SystemExit(f"no job '{gate}' in the workflow")
    needs = jobs[gate].get("needs") or []
    if isinstance(needs, str):
        needs = [needs]
    return sorted(job for job in jobs if job != gate and job not in needs)


def main() -> None:
    path, gate = sys.argv[1], sys.argv[2]
    with open(path, encoding="utf-8") as fh:
        workflow = yaml.safe_load(fh)
    missing = missing_from_gate(workflow, gate)
    if missing:
        raise SystemExit(f"{path}: jobs missing from {gate}.needs: {', '.join(missing)}")
    print(f"{path}: every job feeds {gate}")


if __name__ == "__main__":
    main()
