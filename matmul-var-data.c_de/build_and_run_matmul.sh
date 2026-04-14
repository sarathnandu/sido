#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_CANDIDATES=(
  "${SCRIPT_DIR}/../codeletProbe"
  "${HOME}/program-measurement-scripts/utils/codeletProbe"
  "${HOME}/program-measurement-scripts/samples/nr-codelets/codeletProbe"
)

find_codeletprobe_dir() {
  local candidate
  for candidate in "${DEFAULT_CANDIDATES[@]}"; do
    if [[ -d "${candidate}" && -f "${candidate}/Makefile" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done
  return 1
}

CODELETPROBE_DIR="${CODELETPROBE_DIR:-}"
if [[ -z "${CODELETPROBE_DIR}" ]]; then
  CODELETPROBE_DIR="$(find_codeletprobe_dir || true)"
fi

if [[ -z "${CODELETPROBE_DIR}" ]]; then
  echo "Could not find codeletProbe."
  echo "Set CODELETPROBE_DIR to the directory containing libmeasure Makefile."
  exit 1
fi

if [[ ! -f "${CODELETPROBE_DIR}/Makefile" ]]; then
  echo "Invalid CODELETPROBE_DIR: ${CODELETPROBE_DIR}"
  echo "Expected a Makefile in that directory."
  exit 1
fi

echo "[1/3] Building libmeasure in ${CODELETPROBE_DIR}"
make -C "${CODELETPROBE_DIR}" clean
make -C "${CODELETPROBE_DIR}"

echo "[2/3] Building matmul wrapper in ${SCRIPT_DIR}"
make -C "${SCRIPT_DIR}" clean
make -C "${SCRIPT_DIR}" \
  LIBS="-L${CODELETPROBE_DIR} -lmeasure" \
  LIBPATH="." \
  LDFLAGS="-g -lm -Wl,-rpath,${CODELETPROBE_DIR}"

echo "[3/3] Running wrapper"
(
  cd "${SCRIPT_DIR}"
  LD_LIBRARY_PATH="${CODELETPROBE_DIR}:${LD_LIBRARY_PATH:-}" ./wrapper
)
