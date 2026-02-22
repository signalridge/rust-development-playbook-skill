# Rust Reference Index

Use this page as the default entry point when you are not sure which reference to load first.
This file is the canonical routing map; keep task-to-reference tables here only.

## Fast Route by Task

| Task Category | Start Here | Then Load |
| --- | --- | --- |
| `scaffolding` | `references/scaffolding-blueprints.md` | `references/development-standards.md` |
| `compile/lifetime` | `references/quick-fixes.md` | `references/development-standards.md` |
| `async/tokio` | `references/development-standards.md` | `references/quick-fixes.md` |
| `cargo workflow` | `references/cargo-command-map.md` | `scripts/rust_quality_gate.sh` |
| `toolchain` | `references/official-learning-path.md` | `scripts/check-rust-version.sh` |
| `fuzzing` | `references/fuzzing-cargo-fuzz.md` | `scripts/rust_quality_gate.sh` |
| `release/verification` | `scripts/rust_quality_gate.sh` | `references/development-standards.md` |

## Decision Flow

1. If there is a compiler/lifetime/runtime error, start with `references/quick-fixes.md`.
2. If the task is structural or workflow-oriented, start with `references/development-standards.md`.
3. If bootstrapping or reorganizing crates, start with `references/scaffolding-blueprints.md`.
4. If command selection is unclear, start with `references/cargo-command-map.md`.
5. If Rust version mismatch is suspected, run `scripts/check-rust-version.sh`.
6. If preparing final verification or release artifacts, run `scripts/rust_quality_gate.sh`.
