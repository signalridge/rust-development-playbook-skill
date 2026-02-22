#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  rust_quality_gate.sh [project_dir] [--toolchain <stable|nightly>] [--all-features] [--no-default-features] [--skip-fmt] [--skip-clippy] [--skip-version-check] [--fuzz-target <name>] [--run-fuzz <seconds>]

Options:
  project_dir             Project root path. Default: current directory.
  --toolchain <name>      Cargo toolchain override (stable or nightly).
  --all-features          Pass --all-features to cargo commands.
  --no-default-features   Pass --no-default-features to cargo commands.
  --skip-fmt              Skip rustfmt check.
  --skip-clippy           Skip clippy.
  --skip-version-check    Skip running toolchain compatibility check.
  --fuzz-target <name>    cargo-fuzz target name to run.
  --run-fuzz <seconds>    If > 0, run cargo-fuzz for max_total_time seconds.
  -h, --help              Show this help.
USAGE
}

project_dir="."
toolchain=""
all_features=0
no_default_features=0
skip_fmt=0
skip_clippy=0
skip_version_check=0
fuzz_target=""
run_fuzz=0

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
check_version_script="$script_dir/check-rust-version.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --toolchain)
      [[ $# -ge 2 ]] || {
        echo "ERROR: --toolchain requires a value" >&2
        exit 2
      }
      toolchain="$2"
      shift 2
      ;;
    --all-features)
      all_features=1
      shift
      ;;
    --no-default-features)
      no_default_features=1
      shift
      ;;
    --skip-fmt)
      skip_fmt=1
      shift
      ;;
    --skip-clippy)
      skip_clippy=1
      shift
      ;;
    --skip-version-check)
      skip_version_check=1
      shift
      ;;
    --fuzz-target)
      [[ $# -ge 2 ]] || {
        echo "ERROR: --fuzz-target requires a value" >&2
        exit 2
      }
      fuzz_target="$2"
      shift 2
      ;;
    --run-fuzz)
      [[ $# -ge 2 ]] || {
        echo "ERROR: --run-fuzz requires a numeric value" >&2
        exit 2
      }
      run_fuzz="$2"
      shift 2
      ;;
    -* )
      echo "ERROR: Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      project_dir="$1"
      shift
      ;;
  esac
done

if [[ -n "$toolchain" && ! "$toolchain" =~ ^(stable|nightly)$ ]]; then
  echo "ERROR: --toolchain must be one of: stable, nightly" >&2
  exit 2
fi

if [[ "$run_fuzz" != "0" && ! "$run_fuzz" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --run-fuzz must be an integer >= 0" >&2
  exit 2
fi

[[ -d "$project_dir" ]] || {
  echo "ERROR: project directory not found: $project_dir" >&2
  exit 2
}

cd "$project_dir"

[[ -f "Cargo.toml" ]] || {
  echo "ERROR: Cargo.toml not found in: $(pwd)" >&2
  exit 2
}

run_step() {
  local label="$1"
  shift
  echo "==> $label"
  "$@"
}

cargo_cmd=(cargo)
if [[ -n "$toolchain" ]]; then
  cargo_cmd=(cargo "+$toolchain")
fi

feature_args=()
if [[ "$all_features" -eq 1 ]]; then
  feature_args+=(--all-features)
fi
if [[ "$no_default_features" -eq 1 ]]; then
  feature_args+=(--no-default-features)
fi

if [[ "$skip_version_check" -eq 0 ]]; then
  if [[ -x "$check_version_script" ]]; then
    if [[ "$toolchain" == "nightly" ]]; then
      run_step "Toolchain version check (nightly allowed)" "$check_version_script"
    else
      run_step "Toolchain version check (stable required)" "$check_version_script" --require-stable
    fi
  else
    run_step "Toolchain version check" rustc --version
    run_step "Cargo version" cargo --version
  fi
fi

if [[ "$skip_fmt" -eq 0 ]]; then
  run_step "Formatting check" "${cargo_cmd[@]}" fmt -- --check
fi

if [[ "$skip_clippy" -eq 0 ]]; then
  run_step "Clippy (deny warnings)" "${cargo_cmd[@]}" clippy --workspace --all-targets "${feature_args[@]}" -- -D warnings
fi

run_step "Workspace tests" "${cargo_cmd[@]}" test --workspace "${feature_args[@]}"
run_step "Release build" "${cargo_cmd[@]}" build --workspace --release "${feature_args[@]}"

if [[ "$run_fuzz" -gt 0 ]]; then
  if [[ -z "$fuzz_target" ]]; then
    echo "ERROR: --run-fuzz requires --fuzz-target <name>" >&2
    exit 2
  fi
  if ! command -v cargo-fuzz >/dev/null 2>&1 && ! "${cargo_cmd[@]}" fuzz --help >/dev/null 2>&1; then
    echo "ERROR: cargo-fuzz is required for fuzz runs. Install with: cargo install cargo-fuzz" >&2
    exit 127
  fi
  run_step "Fuzz smoke test ($fuzz_target, ${run_fuzz}s)" "${cargo_cmd[@]}" fuzz run "$fuzz_target" -- -max_total_time="$run_fuzz"
fi

echo "==> Rust quality gate passed"
