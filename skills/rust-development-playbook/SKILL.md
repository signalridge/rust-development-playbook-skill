---
name: rust-development-playbook
description: End-to-end Rust engineering workflow for implementation, refactoring, async Tokio services, project scaffolding, cargo workflow, fuzzing with cargo-fuzz, and release quality gates. Use when tasks touch Rust source files, Cargo.toml/workspaces, toolchain setup, async/runtime issues, or production verification.
---

# Rust Development Playbook

Production workflow for Rust projects. This playbook combines async depth, systems rigor, scaffolding guidance, Cargo execution discipline, and security-focused fuzzing.

## Source Strength Coverage

- `rust-async-patterns`: async runtime model, concurrency control, channels, graceful shutdown.
- `cargo-fuzz`: fuzz target lifecycle, corpus/crash handling, gate integration.
- `rust-pro`: production quality standards, ownership rigor, profiling-first performance tuning.
- `systems-programming-rust-project`: scaffolding blueprints for CLI/web/workspace/library/WASM.
- `rust`/`cargo`/`cargo-rust`: cargo command map, workspace validation defaults.

## When to Use This Skill

- Building or modifying Rust applications/libraries.
- Creating or refactoring Cargo workspaces.
- Designing async services with Tokio.
- Fixing ownership/lifetime/Send-Sync failures.
- Hardening parsers and unsafe boundaries with fuzzing.
- Running pre-merge or pre-release Rust quality gates.

## Core Concepts

### 1. Rust Engineering Primitives

| Primitive | Purpose |
| --- | --- |
| Ownership + borrowing | Memory safety without GC |
| `Result<T, E>` | Explicit error propagation |
| `tokio` runtime | Structured async execution |
| Cargo targets/features | Deterministic build graph |
| `clippy` + `rustfmt` | Code quality baseline |
| `cargo-fuzz` | Coverage-guided robustness checks |

### 2. Safety Model in Practice

- Start with clarity and correctness; optimize after measurement.
- Keep ownership boundaries explicit (`Arc`, `Mutex`, channels, lifetimes).
- Treat `unsafe` as exceptional: isolate and document invariants.
- Run lints and tests before performance claims.

## Quick Start

### New Project

```bash
cargo new myapp
cd myapp
cargo fmt
cargo test
cargo clippy --all-targets -- -D warnings
```

### Existing Project

```bash
rustc --version
cargo --version
cargo fmt -- --check
cargo test
cargo clippy --all-targets -- -D warnings
```

If toolchain mismatch is suspected, run `scripts/check-rust-version.sh`.

## Reference Routing

Use progressive disclosure: load only the reference file needed for the current task.
Use `references/index.md` as the single source of truth for task-to-reference routing.

Quick rule:

- If task intent is ambiguous, start with `references/index.md`.
- If compile/lifetime/runtime failures occur, use `references/quick-fixes.md`.
- If bootstrapping project structure, use `references/scaffolding-blueprints.md`.
- If choosing Cargo commands for build/test/release workflows, use `references/cargo-command-map.md`.
- If hardening parser/input code, use `references/fuzzing-cargo-fuzz.md`.
- If preparing final verification/release checks, run `scripts/rust_quality_gate.sh`.

## Patterns

### Pattern 1: Standard Service Layout

```text
my-service/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── config.rs
│   ├── error.rs
│   ├── api/
│   ├── domain/
│   └── infra/
├── tests/
├── benches/
└── fuzz/
```

Rules:

- Keep domain logic in `lib.rs` modules; keep `main.rs` thin.
- Keep `error.rs` explicit with a clear error taxonomy.
- Prefer workspace split when multiple binaries/crates appear.

### Pattern 2: Async Service Baseline

```rust
use anyhow::Result;
use tokio::signal;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let server = tokio::spawn(async {
        run_server().await
    });

    tokio::select! {
        res = server => {
            res??;
        }
        _ = signal::ctrl_c() => {
            tracing::info!("shutdown signal received");
        }
    }

    Ok(())
}

async fn run_server() -> Result<()> {
    Ok(())
}
```

Rules:

- Keep cancellation behavior explicit.
- Avoid blocking calls inside async tasks (`spawn_blocking` if needed).
- Bound concurrency with semaphores/channels where load can spike.

### Pattern 2b: Channels and Bounded Concurrency

```rust
use tokio::sync::{mpsc, Semaphore};
use std::sync::Arc;

async fn bounded_pipeline() {
    let (tx, mut rx) = mpsc::channel::<String>(128);
    let permits = Arc::new(Semaphore::new(16));

    for i in 0..100 {
        let tx = tx.clone();
        let permits = permits.clone();
        tokio::spawn(async move {
            let _permit = permits.acquire_owned().await.expect("semaphore closed");
            let _ = tx.send(format!("job-{i}")).await;
        });
    }
    drop(tx);

    while let Some(msg) = rx.recv().await {
        tracing::debug!(%msg, "received");
    }
}
```

Rules:

- Prefer bounded channels over unbounded queues for untrusted load.
- Bound producer concurrency explicitly.
- Close senders intentionally to terminate consumers.

### Pattern 3: Error Handling Contract

```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("config error: {0}")]
    Config(String),
    #[error("io error: {0}")]
    Io(#[from] std::io::Error),
}
```

Rules:

- Domain/library crates: typed errors via `thiserror`.
- Binary entrypoints: aggregate with `anyhow` at the boundary.
- Include actionable context, not generic “failed” messages.

### Pattern 4: Cargo Workflow Discipline

```bash
cargo check --workspace
cargo fmt -- --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
cargo build --workspace --release
```

- Default to workspace-wide checks in monorepos.
- Use feature matrices only when required; keep CI matrix intentional.

See `references/cargo-command-map.md` for command selection by task.

### Pattern 5: Fuzzing for Critical Parsers

```bash
cargo install cargo-fuzz
cargo fuzz init
cargo fuzz add parser
cargo fuzz run parser -- -max_total_time=30
```

- Prioritize inputs that cross trust boundaries.
- Seed corpus with valid/invalid edge cases.
- Minimize crashes into regression tests.

### Pattern 6: Performance Profiling Baseline

```bash
cargo test --workspace
cargo bench
cargo build --release
# Optional: cargo flamegraph --bin my-service
```

- Profile before optimization; avoid speculative micro-tuning.
- Keep benchmark cases tied to real production hotspots.
- Verify latency/throughput changes with repeatable measurements.

## Fast Failure Triage

1. Run a fast compile pass:

```bash
cargo check --workspace
```

2. Match compiler/runtime symptoms with:

- `references/quick-fixes.md`

3. Apply the smallest change and re-run:

```bash
cargo test --workspace
```

4. Before final sign-off, run the acceptance gate script.

## Operational Workflow

1. Discover context.

- Locate workspace members, feature flags, async entrypoints, and critical boundaries.

2. Implement minimally.

- Keep scope tight; avoid opportunistic refactors.

3. Verify in order.

- Format, lint, tests, release build, optional fuzz smoke test.

4. Report clearly.

- Commands run, outcomes, residual risks, follow-up work.

## Acceptance Gate

Run the bundled quality gate script before claiming completion:

```bash
scripts/rust_quality_gate.sh <project-dir>
```

Check toolchain compatibility directly when triaging version mismatches:

```bash
scripts/check-rust-version.sh --require-stable
```

Run with fuzz smoke test for parser-heavy services:

```bash
scripts/rust_quality_gate.sh <project-dir> --fuzz-target parser --run-fuzz 30
```

## Best Practices

### Do

- Keep APIs explicit about ownership and mutability.
- Isolate IO and side effects behind testable boundaries.
- Keep feature flags documented and minimal.
- Add regression tests for each production incident.

### Do Not

- Hide errors with `.ok()`/`unwrap()` in production paths.
- Mix blocking operations into async tasks.
- Expand scope with unrelated refactors during bugfixes.
- Skip quality gates before merge/release.
