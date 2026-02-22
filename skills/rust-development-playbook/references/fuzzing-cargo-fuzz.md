# Fuzzing with cargo-fuzz

Use this file for coverage-guided robustness testing of Rust code that parses or handles untrusted input.

## When to Apply

- Parsers, protocol decoders, file readers.
- Unsafe boundaries.
- Serialization/deserialization paths.
- Anything exposed to attacker-controlled input.

## Fuzzer Choice

| Fuzzer | Best For | Complexity |
| --- | --- | --- |
| `cargo-fuzz` | Cargo-based Rust projects, quick setup | Low |
| `AFL++` | Multi-core fuzzing, non-Cargo targets | Medium |
| `LibAFL` | Custom fuzzing engines and research workflows | High |

Default recommendation for Rust projects: start with `cargo-fuzz`.

## Setup

```bash
cargo install cargo-fuzz
cargo fuzz init
cargo fuzz add parser
```

## Target Skeleton

```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = mycrate::parse(data);
});
```

## Execution

```bash
cargo fuzz run parser -- -max_total_time=30
```

Recommended policy:

- Fast smoke fuzz in CI/nightly (`30-120` seconds per critical target).
- Longer fuzz jobs in scheduled pipelines.

## Crash Handling

1. Re-run with generated artifact to confirm reproducibility.
2. Minimize and preserve the crashing input.
3. Add regression unit/integration test.
4. Re-run fuzz target to validate remediation.

## Integration with Quality Gate

`rust_quality_gate.sh` supports optional fuzz execution:

```bash
scripts/rust_quality_gate.sh . --fuzz-target parser --run-fuzz 30
```
