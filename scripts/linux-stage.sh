#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
portable="${root}/portablelinux"
tag="153.0.8010.52-1"
portable_commit="effeae1d0728db00ed21cbf603af88e0fc38f97b"
ungoogled_commit="a638756eb14c8b6ce64b4b2a067afea5d4207bf4"
image="idfri-chromium-builder:trixie-slim"

init() {
  [ ! -e "$portable" ] || { echo "portablelinux already exists" >&2; exit 1; }
  git clone --depth 1 --branch "$tag" --recurse-submodules --shallow-submodules \
    https://github.com/ungoogled-software/ungoogled-chromium-portablelinux.git "$portable"
  [ "$(git -C "$portable" rev-parse HEAD)" = "$portable_commit" ]
  [ "$(git -C "$portable/ungoogled-chromium" rev-parse HEAD)" = "$ungoogled_commit" ]
  cp -a "$root/fingerprint-patches" "$portable/fingerprint-patches"
  cp -a "$root/branding" "$portable/branding"
  cp "$root/idfri_branding.py" "$root/build_linux.sh" "$root/package_linux.sh" "$root/flags.linux.gn" "$portable/"
}

import_cache() {
  mkdir -p "$portable"
  zstd -d -c "$root/.github/cache/build-cache-x86_64.tar.zst" | tar -xf - -C "$portable"
}

export_cache() {
  mkdir -p "$root/.github/cache"
  tar -C "$portable" --exclude='build/download_cache' -cf - build \
    | zstd -f -T0 -3 -o "$root/.github/cache/build-cache-x86_64.tar.zst"
}

run_container() {
  docker run --rm -i \
    -u "$(id -u):$(id -g)" \
    -v "$portable:/repo" \
    ${GITHUB_OUTPUT:+-v "$GITHUB_OUTPUT:$GITHUB_OUTPUT"} \
    -e GITHUB_OUTPUT -e IDFRI_FINAL_STAGE \
    "$image" bash "/repo/$1" "${@:2}"
}

case "${1:-}" in
  init) init ;;
  image) docker buildx build --load -t "$image" -f "$portable/docker/build.Dockerfile" "$portable/docker" ;;
  save-image) docker save "$image" -o /tmp/idfri-linux-builder.tar ;;
  load-image) docker load -i /tmp/idfri-linux-builder.tar ;;
  import-cache) import_cache ;;
  export-cache) export_cache ;;
  prepare) run_container build_linux.sh prepare ;;
  build) run_container build_linux.sh build ;;
  package) run_container package_linux.sh ;;
  *) echo "usage: linux-stage.sh init|image|save-image|load-image|import-cache|export-cache|prepare|build|package" >&2; exit 2 ;;
esac
