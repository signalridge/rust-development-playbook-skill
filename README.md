# rust-development-playbook-skill

Standalone repository for the `rust-development-playbook` skill.

This skill merges the strongest patterns from multiple Rust skill sources:

- `rust-async-patterns` (deep async/Tokio patterns)
- `cargo-fuzz` (security-focused fuzzing workflow)
- `rust-pro` (production-grade Rust system design)
- `systems-programming-rust-project` (scaffolding blueprints)
- `rust`/`cargo`/`cargo-rust` (fast Cargo workflow coverage)

## Coverage Matrix

| Source skill | Integrated strengths in this repo |
| --- | --- |
| `rust-async-patterns` | async service baseline, select/shutdown pattern, channels + bounded concurrency patterns, async failure triage |
| `cargo-fuzz` | `cargo-fuzz` setup, target skeleton, run policy, crash-to-regression workflow, quality gate integration |
| `rust-pro` | ownership/error boundaries, async/runtime constraints, production verification flow, performance profiling baseline |
| `systems-programming-rust-project` | CLI/web/workspace/library/WASM scaffolding blueprints, crate boundary guidance |
| `rust`/`cargo`/`cargo-rust` | cargo command map, workspace-first validation, release gate command sequence |

## Layout

- `.claude-plugin/plugin.json`
- `skills/rust-development-playbook/SKILL.md`
- `skills/rust-development-playbook/references/*`
- `skills/rust-development-playbook/scripts/*`
- `scripts/install-claude-plugin.sh`
- `scripts/install-claude-skill.sh`
- `scripts/install-codex-skill.sh`

## Install

### Claude plugin install

```bash
git clone https://github.com/signalridge/rust-development-playbook-skill.git
cd rust-development-playbook-skill
./scripts/install-claude-plugin.sh
```

### Claude skill install

```bash
./scripts/install-claude-skill.sh --skills-dir "$HOME/.claude/skills"
```

Parameter priority for skills root:

- `--skills-dir`
- `CLAUDE_SKILLS_DIR`
- default: `~/.claude/skills`

Environment variable alternative:

```bash
CLAUDE_SKILLS_DIR="$HOME/.claude/skills" ./scripts/install-claude-skill.sh
```

### Codex skill install

```bash
./scripts/install-codex-skill.sh
```

## Validation Commands

```bash
./skills/rust-development-playbook/scripts/check-rust-version.sh
./skills/rust-development-playbook/scripts/rust_quality_gate.sh <project-dir>
```

Require stable toolchain only:

```bash
./skills/rust-development-playbook/scripts/check-rust-version.sh --require-stable
```

Run quality gate with fuzz smoke test:

```bash
./skills/rust-development-playbook/scripts/rust_quality_gate.sh <project-dir> \
  --fuzz-target parser --run-fuzz 30
```

## chezmoi external extraction

Extract this path into your destination skill directory:

- `skills/rust-development-playbook/**`
