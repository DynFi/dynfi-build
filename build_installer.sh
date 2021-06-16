#!/bin/sh

export SRCCONF=/home/builder/dynfi-src.conf
export MAKEOBJDIRPREFIX=/home/builder/freebsd-obj
export KERNCONF=DYNFI

NCPUS=$(sysctl -n hw.ncpu)

FBSD_TREE=/home/builder/freebsd
FBSD_BRANCH=dynfi-13
PORT_BRANCH=default
DFF_VERSION=$(readlink /usr/home/builder/freebsd-base-repo/${FBSD_BRANCH}/FreeBSD:13:amd64/latest)

IMAGE_TARGET=disc1.iso
IMAGE_NAME=disc1.iso
IMAGE_EXT=.iso

DYNFI_REPO=/home/builder/freebsd-base-repo/${FBSD_BRANCH}

build_installer()
{
    sudo chflags -R noschg ${MAKEOBJDIRPREFIX}/usr/home/builder/freebsd/amd64.amd64/release/
    sudo rm -rf  ${MAKEOBJDIRPREFIX}/usr/home/builder/freebsd/amd64.amd64/release/
    cd ${FBSD_TREE}/release && sudo -E make ${IMAGE_TARGET} WITH_PKGBASE=y REPODIR=${DYNFI_REPO} \
				    DYNFI_REPODIR=/usr/local/poudriere/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/ \
				    PORTSDIR=/usr/local/poudriere/ports/${PORT_BRANCH} \
				    WITH_SERIAL=yes

    mkdir -p ~/image/
    cp ${MAKEOBJDIRPREFIX}/usr/home/builder/freebsd/amd64.amd64/release/${IMAGE_NAME} ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}

    sudo chflags -R noschg ${MAKEOBJDIRPREFIX}/usr/home/builder/freebsd/amd64.amd64/release/
    sudo rm -rf ${MAKEOBJDIRPREFIX}/usr/home/builder/freebsd/amd64.amd64/release/
    cd ${FBSD_TREE}/release && sudo -E make ${IMAGE_TARGET} WITH_PKGBASE=y REPODIR=${DYNFI_REPO} \
				    DYNFI_REPODIR=/usr/local/poudriere/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/ \
				    PORTSDIR=/usr/local/poudriere/ports/${PORT_BRANCH}

    mkdir -p ~/image/
    cp ${MAKEOBJDIRPREFIX}/usr/home/builder/freebsd/amd64.amd64/release/${IMAGE_NAME} ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}

    bzip2 -v -9 ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}
    bzip2 -v -9 ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}

    cat ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 | sha256 > ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256
    cat ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 | sha256 > ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256

    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2
    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2
    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256
    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256
}

if [ -f /tmp/build-dynfi.pid ]; then
    echo "A build is already in progress"
    exit 1
fi
echo $$ > /tmp/build-dynfi.pid

#date=$(date "+%Y%m%d-%H%M%S")
date=$(date "+%Y%m%d-%H%M")

mkdir -p /tmp/builder_logs_${date}

build_installer 2>&1 | tee -a /tmp/builder_logs_${date}/build_installer.log

rm /tmp/build-dynfi.pid
