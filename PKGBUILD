# Maintainer: 9M2PJU <9m2pju@gmail.com>
pkgname=uvprotermbt-9m2pju-bin
pkgver=0.9.7
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

source_x86_64=("${pkgname}-${pkgver}-x86_64.AppImage::https://github.com/9M2PJU/UVProTermBT/releases/download/v${pkgver}/uvprotermbt-${pkgver}-x86_64.AppImage")
source_aarch64=("${pkgname}-${pkgver}-aarch64.AppImage::https://github.com/9M2PJU/UVProTermBT/releases/download/v${pkgver}/uvprotermbt-${pkgver}-aarch64.AppImage")

sha256sums_x86_64=('911e752b77d377632e76952c6994a2c4db8769d734c28de325d33b63cae68415')
sha256sums_aarch64=('336231f4974b0a0d73425c0d78c7193cf82806c54210899187afb68d7f78b348')

prepare() {
  case "${CARCH}" in
    x86_64)  _appimg="${pkgname}-${pkgver}-x86_64.AppImage" ;;
    aarch64) _appimg="${pkgname}-${pkgver}-aarch64.AppImage" ;;
  esac

  chmod +x "${_appimg}"
  rm -rf squashfs-root
  ./"${_appimg}" --appimage-extract >/dev/null
}

package() {
  install -d "${pkgdir}/opt/${pkgname}"
  cp -r squashfs-root/* "${pkgdir}/opt/${pkgname}/"

  install -d "${pkgdir}/usr/bin"
  ln -s "/opt/${pkgname}/AppRun" "${pkgdir}/usr/bin/uvprotermbt"

  if [ -d "squashfs-root/usr/share/applications" ]; then
    install -d "${pkgdir}/usr/share/applications"
    install -m644 squashfs-root/usr/share/applications/*.desktop "${pkgdir}/usr/share/applications/"
  fi

  if [ -d "squashfs-root/usr/share/icons" ]; then
    install -d "${pkgdir}/usr/share/icons"
    cp -r squashfs-root/usr/share/icons/* "${pkgdir}/usr/share/icons/"
  fi

  if [ -d "squashfs-root/usr/share/man" ]; then
    install -d "${pkgdir}/usr/share/man"
    cp -r squashfs-root/usr/share/man/* "${pkgdir}/usr/share/man/"
  fi
}
