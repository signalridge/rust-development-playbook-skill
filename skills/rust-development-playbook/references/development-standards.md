# Rust Development Standards

## 1. Structure

- Keep `Cargo.toml` intentional; avoid dependency sprawl.
- Prefer workspace layout once multiple crates or binaries emerge.
- Keep `main.rs` thin and push logic into testable modules.

## 2. Formatting and Linting

- Run `cargo fmt -- --check`.
- Run `cargo clippy --workspace --all-targets -- -D warnings`.
- Use `#![deny(unsafe_op_in_unsafe_fn)]` for crates with unsafe usage.

## 3. Error Handling

- Use `thiserror` for library/domain errors.
- Use `anyhow` only at application boundaries.
- Add context at boundaries (`.context(...)`) when debugging would otherwise be ambiguous.

## 4. Async and Concurrency

- Do not block in async paths; use `tokio::task::spawn_blocking`.
- Keep cancellation and shutdown paths explicit.
- Bound concurrency (`Semaphore`, bounded channels) under untrusted load.

## 5. Ownership and API Contracts

- Prefer borrowing over cloning until clone is justified.
- Document ownership of returned buffers/handles.
- Keep `Send`/`Sync` assumptions explicit in trait bounds.

## 6. Testing Minimum

```bash
cargo test --workspace
cargo test --workspace --release
```

For parser-heavy or untrusted input systems, add fuzz smoke tests in CI/nightly.

## 7. Verification Minimum

```bash
cargo fmt -- --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
cargo build --workspace --release
```

## 8. Performance Baseline

- Measure before optimizing; no speculative tuning.
- Use representative benchmark inputs.
- Keep profiling commands reproducible.

Suggested workflow:

```bash
cargo bench
cargo build --release
# Optional: cargo flamegraph --bin <service-bin>
```
