# UVProTermBT-9M2PJU-AUR

AUR package source repository for `uvprotermbt-9m2pju-bin`.

This repository contains the `PKGBUILD` and `.SRCINFO` for installing **UVProTermBT** prebuilt binary releases on Arch Linux.

Main Project Repository: [https://github.com/9M2PJU/UVProTermBT](https://github.com/9M2PJU/UVProTermBT)

## Installation (Arch Linux / Manjaro / EndeavourOS)

### Using an AUR Helper (Recommended)

```bash
yay -S uvprotermbt-9m2pju-bin
# or
paru -S uvprotermbt-9m2pju-bin
```

### Manual Installation with `makepkg`

```bash
git clone https://github.com/9M2PJU/UVProTermBT-9M2PJU-AUR.git
cd UVProTermBT-9M2PJU-AUR
makepkg -si
```

## Maintenance & Publishing to AUR

To update `PKGBUILD` and `.SRCINFO` and push directly to `aur.archlinux.org`:

```bash
./push-aur.sh
```
