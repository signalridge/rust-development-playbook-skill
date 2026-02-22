# Rust Official Learning Path

## Primary Sources

1. The Rust Book:

- https://doc.rust-lang.org/book/

2. Rust by Example:

- https://doc.rust-lang.org/rust-by-example/

3. Cargo Book:

- https://doc.rust-lang.org/cargo/

4. Rust Reference:

- https://doc.rust-lang.org/reference/

5. Rust API docs:

- https://doc.rust-lang.org/std/

6. Async runtime docs (Tokio):

- https://docs.rs/tokio/latest/tokio/

7. Clippy lints:

- https://doc.rust-lang.org/clippy/

## Recommended Reading Sequence

1. Rust Book (ownership, traits, lifetimes)
2. Cargo Book (workspaces, features, profiles)
3. Tokio docs (async tasks, channels, cancellation)
4. Rust Reference for edge semantics
5. Clippy docs for policy tuning

## Baseline Commands

```bash
rustc --version
cargo --version
cargo fmt -- --check
cargo clippy --all-targets -- -D warnings
cargo test
cargo build --release
```
