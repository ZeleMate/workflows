# Fixture projects

Each folder is the language project from a render of [repo-template](https://github.com/ZeleMate/repo-template), so CI runs `python.yml`, `typescript.yml` and `rust.yml` against the same files a generated repo has. They are test inputs, not code to maintain.

To refresh one after a template release, render the template with that single language and copy the project files over:

```bash
uvx copier copy --trust --defaults -d project_name=Fixture -d author_name=Fixture \
  -d author_email=fixture@example.com -d github_owner=example -d visibility=public \
  -d license=MIT -d 'languages=["rust"]' -d agentic=false -d publishes=false \
  gh:ZeleMate/repo-template /tmp/fixture-rust
```

`Cargo.lock` comes from `cargo generate-lockfile` (in a `rust` container if cargo isn't installed).
