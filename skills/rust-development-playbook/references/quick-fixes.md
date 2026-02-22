# Rust Quick Fixes

Use this file when `cargo check`, `cargo clippy`, or `cargo test` fails and you need high-confidence fixes first.

## Workflow

1. Run `cargo check --workspace`.
2. Match the error text with the table below.
3. Apply the smallest fix.
4. Re-run `cargo test --workspace`.
5. Run `scripts/rust_quality_gate.sh` before final sign-off.

## High-Frequency Fix Table

| Error Symptom | Likely Cause | Minimal Fix |
| --- | --- | --- |
| `future cannot be sent between threads safely` | Captured non-`Send` type in spawned task | Use `tokio::spawn` only with `Send + 'static`; move non-Send work to `LocalSet` or refactor ownership |
| `borrowed value does not live long enough` | Reference outlives owner | Return owned data (`String`, `Vec`) or move allocation to caller scope |
| `use of moved value` | Ownership moved earlier | Borrow (`&T`/`&mut T`) or clone intentionally at boundary |
| `cannot borrow as mutable more than once` | Overlapping mutable borrows | Narrow borrow scopes or split data structures |
| `blocking in async context` warnings | Sync IO/CPU in async task | Use `tokio::task::spawn_blocking` |
| `feature ... is required` compile errors | Missing feature flags | Enable feature in `Cargo.toml` and keep flag documented |
| `clippy::unwrap_used` or panic risks | `unwrap()` on runtime paths | Replace with `?`, explicit matches, or domain errors |

## Tokio Runtime Mismatch

**Symptom:** `cannot start a runtime from within a runtime`

**Fix:**

- Remove nested `#[tokio::main]` usage.
- Pass runtime handle or make inner function `async` and await it.

## Trait Object Send/Sync

**Symptom:** trait object fails thread-safety bounds.

**Fix:**

- Add `+ Send + Sync` where shared across threads.
- If truly single-threaded, confine to single-thread executor and document constraint.

## Feature Explosion

**Symptom:** matrix of feature combinations becomes unstable.

**Fix:**

- Keep one default feature set + one minimal set.
- Add targeted tests for each supported profile.
- Remove speculative flags with no production owner.

## Fuzz Crash Follow-up

After any fuzz crash:

1. Save minimized input to `fuzz/corpus/<target>/`.
2. Convert crash into deterministic regression test.
3. Re-run short fuzz session to validate fix.
