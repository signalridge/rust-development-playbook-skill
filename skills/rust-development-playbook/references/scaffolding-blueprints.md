# Rust Scaffolding Blueprints

Use this file when creating new Rust projects or reshaping existing codebases into maintainable layouts.

## Blueprint 1: CLI / Binary App

```text
my-cli/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── cli.rs
│   ├── command/
│   ├── config.rs
│   └── error.rs
└── tests/
```

Bootstrap:

```bash
cargo new my-cli
cd my-cli
cargo add clap thiserror anyhow
```

## Blueprint 2: Web Service

```text
my-service/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── api/
│   ├── domain/
│   ├── infra/
│   ├── config.rs
│   └── error.rs
├── tests/
└── fuzz/
```

Bootstrap:

```bash
cargo new my-service
cd my-service
cargo add tokio --features full
cargo add axum tracing tracing-subscriber thiserror anyhow
```

## Blueprint 3: Workspace

```text
my-workspace/
├── Cargo.toml
├── crates/
│   ├── app/
│   ├── core/
│   └── adapters/
└── tools/
```

Workspace root `Cargo.toml`:

```toml
[workspace]
members = ["crates/*", "tools/*"]
resolver = "2"
```

Guidelines:

- Keep domain crate independent of runtime/framework details.
- Keep adapter crate boundaries explicit (db/http/queue).
- Use `cargo check --workspace` as the default fast validation command.

## Blueprint 4: Library Crate

```text
my-lib/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── error.rs
│   └── module/
├── tests/
└── examples/
```

Bootstrap:

```bash
cargo new my-lib --lib
cd my-lib
cargo add thiserror
```

Guidelines:

- Keep public API in `lib.rs` explicit and minimal.
- Add usage examples in `examples/` for integration-level guidance.

## Blueprint 5: WebAssembly App/Library

```text
my-wasm/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   └── bindings.rs
└── tests/
```

Bootstrap:

```bash
cargo new my-wasm --lib
cd my-wasm
cargo add wasm-bindgen
```

Guidelines:

- Keep host boundary types explicit and serialization-safe.
- Validate target-specific builds in CI (`wasm32-unknown-unknown`).
