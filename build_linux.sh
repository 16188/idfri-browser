#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/scripts/shared.sh"
setup_paths

case "${1:-}" in
  prepare)
    fetch_sources false
    apply_patches
    if [ ! -f "${_src_dir}/.idfri-patched.stamp" ]; then
      "${_main_repo}/utils/patches.py" apply "${_src_dir}" "${_root}/fingerprint-patches"
      python3 "${_root}/idfri_branding.py" "${_src_dir}"
      touch "${_src_dir}/.idfri-patched.stamp"
    fi
    apply_domsub
    write_gn_args
    fix_tool_downloading
    setup_toolchain
    gn_gen
    ;;
  build)
    cd "${_src_dir}"
    set +e
    timeout -k 5m -s INT 18000s ninja -C out/Default chrome chromedriver
    rc=$?
    set -e
    if [ "$rc" -eq 124 ] && [ "${IDFRI_FINAL_STAGE:-false}" != true ]; then
      echo "status=running" >> "${GITHUB_OUTPUT}"
      exit 0
    fi
    if [ "$rc" -eq 0 ] && [ -x "${_out_dir}/chrome" ] && [ -x "${_out_dir}/chromedriver" ]; then
      echo "status=completed" >> "${GITHUB_OUTPUT}"
      exit 0
    fi
    exit "$rc"
    ;;
  *)
    echo "usage: build_linux.sh prepare|build" >&2
    exit 2
    ;;
esac
