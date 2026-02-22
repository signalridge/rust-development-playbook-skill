#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  check-rust-version.sh [--min-rustc <version>] [--require-stable]

Options:
  --min-rustc <version>  Minimum rustc version required (default: 1.75.0).
  --require-stable       Fail unless active toolchain is stable.
  -h, --help             Show this help.

Environment:
  RUSTC_CMD              rustc executable to use (default: rustc).
  CARGO_CMD              cargo executable to use (default: cargo).
USAGE
}

min_rustc="1.75.0"
require_stable=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min-rustc)
      [[ $# -ge 2 ]] || {
        echo "ERROR: --min-rustc requires a value" >&2
        exit 2
      }
      min_rustc="$2"
      shift 2
      ;;
    --require-stable)
      require_stable=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

rustc_cmd="${RUSTC_CMD:-rustc}"
cargo_cmd="${CARGO_CMD:-cargo}"

if ! command -v "$rustc_cmd" >/dev/null 2>&1; then
  echo "ERROR: '$rustc_cmd' not found in PATH." >&2
  exit 127
fi

if ! command -v "$cargo_cmd" >/dev/null 2>&1; then
  echo "ERROR: '$cargo_cmd' not found in PATH." >&2
  exit 127
fi

version_ge() {
  local a="$1"
  local b="$2"
  local a_major a_minor a_patch
  local b_major b_minor b_patch

  IFS='.' read -r a_major a_minor a_patch <<<"$a"
  IFS='.' read -r b_major b_minor b_patch <<<"$b"

  a_major="${a_major:-0}"
  a_minor="${a_minor:-0}"
  a_patch="${a_patch:-0}"
  b_major="${b_major:-0}"
  b_minor="${b_minor:-0}"
  b_patch="${b_patch:-0}"

  if (( a_major > b_major )); then
    return 0
  fi
  if (( a_major < b_major )); then
    return 1
  fi

  if (( a_minor > b_minor )); then
    return 0
  fi
  if (( a_minor < b_minor )); then
    return 1
  fi

  if (( a_patch >= b_patch )); then
    return 0
  fi

  return 1
}

rustc_raw="$($rustc_cmd --version)"
cargo_raw="$($cargo_cmd --version)"

if [[ ! "$rustc_raw" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  echo "ERROR: Unable to parse rustc version from: $rustc_raw" >&2
  exit 2
fi
rustc_ver="${BASH_REMATCH[1]}"

echo "Detected rustc: $rustc_raw"
echo "Detected cargo: $cargo_raw"

if ! version_ge "$rustc_ver" "$min_rustc"; then
  echo "ERROR: rustc $rustc_ver is below required minimum $min_rustc" >&2
  exit 1
fi

if [[ "$require_stable" -eq 1 ]]; then
  if [[ "$rustc_raw" =~ nightly|beta ]]; then
    echo "ERROR: stable toolchain required, but found: $rustc_raw" >&2
    exit 1
  fi

  if command -v rustup >/dev/null 2>&1; then
    active_toolchain="$(rustup show active-toolchain 2>/dev/null || true)"
    if [[ -n "$active_toolchain" && "$active_toolchain" =~ nightly|beta ]]; then
      echo "ERROR: stable toolchain required, active: $active_toolchain" >&2
      exit 1
    fi
  fi
fi

echo "OK: rust toolchain check passed"
