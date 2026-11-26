#!/usr/bin/env bash
set -euo pipefail

# Build a versioned AngelOS 11 ISO using mkarchiso.
# Reads SemVer from VERSION (or ANGELOS_VERSION env override).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE_DIR="${REPO_ROOT}/iso/archiso-profile"
WORK_DIR="${WORK_DIR:-${REPO_ROOT}/work}"
OUT_DIR="${OUT_DIR:-${REPO_ROOT}/out}"

if [[ ${EUID} -ne 0 ]]; then
    echo "Error: build-iso.sh must be run as root (mkarchiso requires root)." >&2
    exit 1
fi

if ! command -v mkarchiso >/dev/null 2>&1; then
    echo "Error: mkarchiso not found. Install 'archiso' first (pacman -S archiso)." >&2
    exit 1
fi

VERSION_VAL="${ANGELOS_VERSION:-$(tr -d '[:space:]' < "${REPO_ROOT}/VERSION")}"
if [[ ! "${VERSION_VAL}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
    echo "Error: Invalid SemVer '${VERSION_VAL}'." >&2
    exit 1
fi

export ANGELOS_VERSION="${VERSION_VAL}"

mkdir -p "${WORK_DIR}" "${OUT_DIR}"
rm -rf "${WORK_DIR:?}/"*

echo "==> Building AngelOS 11 v${ANGELOS_VERSION} ISO..."
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"

BUILT_ISO="$(find "${OUT_DIR}" -maxdepth 1 -type f -name "angelos-11-${ANGELOS_VERSION}*.iso" | head -n 1 || true)"
TARGET_ISO="${OUT_DIR}/angelos-11-v${ANGELOS_VERSION}-x86_64.iso"

if [[ -n "${BUILT_ISO}" && "${BUILT_ISO}" != "${TARGET_ISO}" ]]; then
    mv -f "${BUILT_ISO}" "${TARGET_ISO}"
fi

if [[ -f "${TARGET_ISO}" ]]; then
    echo "==> ISO ready: ${TARGET_ISO}"
else
    echo "==> Build finished. Files in ${OUT_DIR}:"
    ls -la "${OUT_DIR}"
fi
