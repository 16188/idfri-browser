#!/usr/bin/env python3
"""Apply the IDFRI product layer to a prepared Chromium source tree."""

import shutil
import sys
from pathlib import Path


def replace_required(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise RuntimeError(f"expected branding token is missing: {old} in {path}")
    path.write_text(text.replace(old, new), encoding="utf-8")


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: idfri_branding.py <chromium-source>")
    source = Path(sys.argv[1]).resolve()
    branding = source / "chrome/app/theme/chromium/BRANDING"
    if not branding.is_file():
        raise RuntimeError("Chromium branding file is unavailable")
    branding.write_text(
        "COMPANY_FULLNAME=IDFRI\n"
        "COMPANY_SHORTNAME=IDFRI\n"
        "PRODUCT_FULLNAME=IDFRI Browser\n"
        "PRODUCT_SHORTNAME=IDFRI Browser\n"
        "PRODUCT_INSTALLER_FULLNAME=IDFRI Browser 安装程序\n"
        "PRODUCT_INSTALLER_SHORTNAME=IDFRI Browser 安装程序\n"
        "COPYRIGHT=Copyright @LASTCHANGE_YEAR@ IDFRI. Chromium contributors retain their respective copyrights.\n"
        "MAC_BUNDLE_ID=com.idfri.browser\n"
        "MAC_CREATOR_CODE=IDFR\n"
        "MAC_TEAM_ID=\n",
        encoding="utf-8",
    )

    for relative in (
        "chrome/app/resources/chromium_strings_zh-CN.xtb",
        "chrome/app/resources/generated_resources_zh-CN.xtb",
    ):
        replace_required(source / relative, "Chromium", "IDFRI Browser")

    icon = Path(__file__).resolve().parent / "branding/idfri.ico"
    if not icon.is_file():
        raise RuntimeError("IDFRI browser icon is unavailable")
    shutil.copyfile(icon, source / "chrome/app/theme/chromium/win/chromium.ico")

    product = branding.read_text(encoding="utf-8")
    if "PRODUCT_FULLNAME=IDFRI Browser" not in product or "COMPANY_FULLNAME=IDFRI" not in product:
        raise RuntimeError("IDFRI product branding was not applied")
    print("IDFRI Browser 品牌已应用：简体中文、IDFRI、https://github.com/16188/idfri-browser")


if __name__ == "__main__":
    main()
