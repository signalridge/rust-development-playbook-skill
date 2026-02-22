# Cargo Command Map

Use this file when you need a direct command choice for a Rust workflow stage.

## Build and Compile

```bash
cargo check --workspace
cargo build --workspace
cargo build --workspace --release
```

- Use `check` for the fastest compile feedback.
- Use `build --release` only after tests/lints pass.

## Test and Verification

```bash
cargo test --workspace
cargo test --workspace --release
cargo clippy --workspace --all-targets -- -D warnings
cargo fmt -- --check
```

- Keep clippy warnings denied in CI and quality gates.
- Run release tests for performance-sensitive crates.

## Feature Matrix

```bash
cargo test --workspace --all-features
cargo test --workspace --no-default-features
```

- Keep supported feature sets minimal and documented.
- Avoid exploding feature combinations without owners.

## Workspace Management

```bash
cargo metadata --format-version 1
cargo tree
cargo update
```

- Use `cargo metadata` for tooling and dependency graph introspection.
- Use `cargo tree` before introducing new shared dependencies.

## Security and Fuzzing

```bash
cargo install cargo-fuzz
cargo fuzz init
cargo fuzz run <target> -- -max_total_time=30
```

- Treat fuzz targets as tests for untrusted input boundaries.
- Convert fuzz crashes into deterministic regression tests.

