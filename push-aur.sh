#!/usr/bin/env bash
# Push/update the uvprotermbt-9m2pju-bin AUR package.
# Usage:
#   packaging/aur/push-aur.sh          # auto-detect latest release from GitHub
#   packaging/aur/push-aur.sh 0.9.7    # specify explicit version
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGNAME="uvprotermbt-9m2pju-bin"
AUR_URL="ssh://aur@aur.archlinux.org/${PKGNAME}.git"

VERSION_ARG="${1:-}"

# Extract version and sha256 digests using python
read -r VERSION X86_64_DIGEST AARCH64_DIGEST < <(python3 -c '
import sys, json, urllib.request, hashlib

ver_input = "'"$VERSION_ARG"'"
if not ver_input:
    url = "https://api.github.com/repos/9M2PJU/UVProTermBT/releases/latest"
else:
    ver_clean = ver_input.lstrip("v")
    url = f"https://api.github.com/repos/9M2PJU/UVProTermBT/releases/tags/v{ver_clean}"

req = urllib.request.Request(url, headers={"User-Agent": "Python/AUR-Publisher"})
try:
    with urllib.request.urlopen(req) as resp:
        rel = json.loads(resp.read().decode())
except Exception as e:
    sys.exit(f"Failed to fetch release info: {e}")

version = rel.get("tag_name", "").lstrip("v")
x86_sha = ""
aarch_sha = ""

for asset in rel.get("assets", []):
    name = asset.get("name", "")
    digest = asset.get("digest", "")
    if digest.startswith("sha256:"):
        digest = digest[7:]
    if name == f"uvprotermbt-{version}-x86_64.AppImage":
        x86_sha = digest
    elif name == f"uvprotermbt-{version}-aarch64.AppImage":
        aarch_sha = digest

print(f"{version} {x86_sha} {aarch_sha}")
')

if [ -z "$VERSION" ] || [ -z "$X86_64_DIGEST" ] || [ -z "$AARCH64_DIGEST" ]; then
    echo "!! Error resolving release assets/digests for version: $VERSION" >&2
    exit 1
fi

echo "==> Preparing AUR package $PKGNAME for version v${VERSION}..."
echo "    x86_64 sha256:  ${X86_64_DIGEST}"
echo "    aarch64 sha256: ${AARCH64_DIGEST}"

cat << EOF > "$HERE/PKGBUILD"
# Maintainer: 9M2PJU <9m2pju@gmail.com>
pkgname=${PKGNAME}
pkgver=${VERSION}
pkgrel=1
pkgdesc="AX.25 packet messenger + terminal for BTech UV-Pro / VGC VR-N76 over Bluetooth KISS TNC (Prebuilt binary)"
arch=('x86_64' 'aarch64')
url="https://github.com/9M2PJU/UVProTermBT"
license=('GPL-3.0-only')
depends=('glibc' 'zlib' 'hicolor-icon-theme' 'bluez' 'polkit')
optdepends=(
  'fuse2: optional, for running original AppImage directly'
  'ax25-tools: AX.25 kernel utilities'
)
provides=('uvprotermbt')
conflicts=('uvprotermbt' 'uvprotermbt-git')
options=('!strip')

source_x86_64=("\${pkgname}-\${pkgver}-x86_64.AppImage::https://github.com/9M2PJU/UVProTermBT/releases/download/v\${pkgver}/uvprotermbt-\${pkgver}-x86_64.AppImage")
source_aarch64=("\${pkgname}-\${pkgver}-aarch64.AppImage::https://github.com/9M2PJU/UVProTermBT/releases/download/v\${pkgver}/uvprotermbt-\${pkgver}-aarch64.AppImage")

sha256sums_x86_64=('${X86_64_DIGEST}')
sha256sums_aarch64=('${AARCH64_DIGEST}')

prepare() {
  case "\${CARCH}" in
    x86_64)  _appimg="\${pkgname}-\${pkgver}-x86_64.AppImage" ;;
    aarch64) _appimg="\${pkgname}-\${pkgver}-aarch64.AppImage" ;;
  esac

  chmod +x "\${_appimg}"
  rm -rf squashfs-root
  ./"\${_appimg}" --appimage-extract >/dev/null
}

package() {
  install -d "\${pkgdir}/opt/\${pkgname}"
  cp -r squashfs-root/* "\${pkgdir}/opt/\${pkgname}/"

  install -d "\${pkgdir}/usr/bin"
  ln -s "/opt/\${pkgname}/AppRun" "\${pkgdir}/usr/bin/uvprotermbt"

  if [ -d "squashfs-root/usr/share/applications" ]; then
    install -d "\${pkgdir}/usr/share/applications"
    install -m644 squashfs-root/usr/share/applications/*.desktop "\${pkgdir}/usr/share/applications/"
  fi

  if [ -d "squashfs-root/usr/share/icons" ]; then
    install -d "\${pkgdir}/usr/share/icons"
    cp -r squashfs-root/usr/share/icons/* "\${pkgdir}/usr/share/icons/"
  fi

  if [ -d "squashfs-root/usr/share/man" ]; then
    install -d "\${pkgdir}/usr/share/man"
    cp -r squashfs-root/usr/share/man/* "\${pkgdir}/usr/share/man/"
  fi
}
EOF

(cd "$HERE" && makepkg --printsrcinfo > .SRCINFO)
echo "==> Updated PKGBUILD and .SRCINFO"

WORK_DIR="/tmp/aur-${PKGNAME}"
rm -rf "$WORK_DIR"

echo "==> Cloning AUR repository..."
if ! git clone "$AUR_URL" "$WORK_DIR"; then
    echo
    echo "!! Failed to clone AUR repository ($AUR_URL)."
    echo "!! If AUR is currently undergoing maintenance (aur.archlinux.org), run this script again once maintenance completes:"
    echo "   packaging/aur/push-aur.sh ${VERSION}"
    exit 1
fi

cp "$HERE/PKGBUILD" "$WORK_DIR/PKGBUILD"
cp "$HERE/.SRCINFO" "$WORK_DIR/.SRCINFO"

cd "$WORK_DIR"
git add PKGBUILD .SRCINFO
if git diff --staged --quiet; then
    echo "==> No changes to commit in AUR repo."
else
    git commit -m "Update to v${VERSION}"
    echo "==> Pushing to AUR..."
    git push origin master
    echo "==> Successfully pushed ${PKGNAME} v${VERSION} to AUR!"
fi
