# workflows

Reusable GitHub Actions workflows for CI and security scanning. Repos call them by reference, so a toolchain or scanner fix is one pin bump in each caller, not a copy of the workflow.

## Workflows

| Workflow | What it runs | Inputs |
|---|---|---|
| `repo-lint.yml` | The caller's pre-commit hooks, and a check that every job in the caller's `ci.yml` is in its merge gate's `needs` | `skip-hooks`, `ci-workflow`, `merge-gate-job` (all optional) |
| `python.yml` | uv, Ruff, pyright or mypy, pytest with coverage on each Python version, 90% changed-line coverage on PRs | `python-versions` (required JSON list, lowest first), `type-checker`, `working-directory` |
| `typescript.yml` | pnpm, Prettier, lint, type check, Vitest with coverage, 90% changed-line coverage on PRs, build | `working-directory`, `node-version` |
| `rust.yml` | rustfmt, clippy, nextest, doc tests, cargo-deny, on the toolchain in `rust-toolchain.toml` | `working-directory` |
| `go.yml` | golangci-lint (format check and lint), `go vet`, `go mod tidy -diff` and `go mod verify`, build, `go test -race` with coverage on each Go version, 90% changed-line coverage on PRs on the first (floor) version, govulncheck on the last | `go-versions` (required JSON list, lowest first), `working-directory` |
| `security.yml` | OSV-Scanner on lockfiles, Gitleaks on full history, and Semgrep when `sast` is true | `sast` |

No workflow takes a secret.

## Calling a workflow

Pin the full commit SHA of a release tag, with the tag as a comment on the same line. Every call in one file pins the same SHA.

```yaml
permissions: {}

jobs:
  python:
    uses: ZeleMate/workflows/.github/workflows/python.yml@<40-character sha>  # v1.0.0
    permissions:
      contents: read
    with:
      python-versions: '["3.13", "3.14"]'
```

The caller grants `contents: read` to each calling job. A called workflow can only lower that.

Keep one merge gate job in the caller (`ci-ok` by default) that `needs` every other job and is the single required status check. `repo-lint.yml` fails if a job is missing from it.

## What the caller's repo must provide

- **Python:** `pyproject.toml` and `uv.lock` with Ruff, pytest, pytest-cov and the chosen type checker as dev dependencies.
- **TypeScript:** `package.json` with a `packageManager` pnpm pin and the scripts `format:check`, `lint`, `typecheck`, `test:coverage` (writing `coverage/cobertura-coverage.xml`) and `build`.
- **Rust:** `rust-toolchain.toml`, `Cargo.lock` and `deny.toml`.
- **Go:** `go.mod` (and `go.sum` once it has dependencies) whose `go` line is no newer than the first entry of `go-versions`, and a golangci-lint v2 `.golangci.yml` next to it.
- **repo-lint:** `.pre-commit-config.yaml`.

## How the tools are pinned

Semgrep, diff-cover and pre-commit are locked with hashes in `tools/uv.lock`, and govulncheck and gocover-cobertura with `tool` directives in `tools/go/go.mod` and `go.sum`. A workflow that needs them checks this repo out at the SHA the caller pinned (`job.workflow_sha`), so a workflow and its tools always come from one commit. Actions are pinned to commit SHAs. Gitleaks, OSV-Scanner and golangci-lint are downloaded by version and verified against a checksum.

golangci-lint can't lint code for a Go newer than the Go it was built with. At each Go release, move its pin in `go.yml` to a build made with the new Go and cut a release before callers raise the newest Go version they test.

## Testing

This repo's own CI calls every workflow: `repo-lint` and `security` on this repo, and `python`, `typescript`, `rust` and `go` on the fixture projects in `tests/fixtures/`, which are renders of the repo template. An action bump or tool change here is therefore tested before it is released.

## Releases

Tags are semver. A release is major when it removes or renames an input, adds a required input, or can turn a green caller red without an edit to the caller: a stricter default rule, a raised minimum version, a new check that is on by default.

## Licence

MIT.
