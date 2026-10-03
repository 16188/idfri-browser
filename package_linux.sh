#!/bin/bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/scripts/shared.sh"
setup_paths

version="153.0.8010.52-1.idfri3"
name="idfri-browser_${version}_linux_x64"
release_dir="${_build_dir}/release"
package_dir="${release_dir}/${name}"

[ -x "${_out_dir}/chrome" ]
[ -x "${_out_dir}/chromedriver" ]

config='{"schema_version":1,"navigator":{"hardwareConcurrency":6}}'
probe="$(printf '%s' "$config" | timeout 90s "${_out_dir}/chrome" \
  --fury-fp-fd=0 --headless=new --no-sandbox --disable-gpu \
  --dump-dom 'data:text/html,<body><script>document.body.textContent=navigator.hardwareConcurrency</script>')"
grep -q '<body>6</body>' <<<"$probe"

mkdir -p "$package_dir"
files=(
  chrome chrome_100_percent.pak chrome_200_percent.pak chrome_crashpad_handler
  chromedriver chrome-wrapper icudtl.dat libEGL.so libGLESv2.so libqt5_shim.so
  libqt6_shim.so libvk_swiftshader.so libvulkan.so.1 locales product_logo_48.png
  resources.pak v8_context_snapshot.bin vk_swiftshader_icd.json xdg-mime xdg-settings
)
for file in "${files[@]}"; do
  cp -a "${_out_dir}/${file}" "$package_dir/"
done
cp "${_root}/LICENSE" "$package_dir/IDFRI-LICENSE.txt"
cp "${_root}/fingerprint-patches/LICENSE" "$package_dir/FINGERPRINT-PATCHES-LICENSE.txt"

mkdir -p "$release_dir"
tar -C "$release_dir" -cJf "${release_dir}/${name}.tar.xz" "$name"
(
  cd "$release_dir"
  archive_sha="$(sha256sum "${name}.tar.xz" | cut -d' ' -f1)"
  chrome_sha="$(sha256sum "${name}/chrome" | cut -d' ' -f1)"
  printf '%s  %s\n' "$archive_sha" "${name}.tar.xz" > SHA256SUMS-linux.txt
  printf '{\n  "version": "%s",\n  "archive": "%s",\n  "archiveSha256": "%s",\n  "chromeSha256": "%s"\n}\n' \
    "$version" "${name}.tar.xz" "$archive_sha" "$chrome_sha" > idfri-browser-linux.json
)
echo "${release_dir}/${name}.tar.xz"
