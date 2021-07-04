#!/bin/sh

. common.subr
. common_start.subr

DFF_VERSION=$(readlink ${DYNFIWRKDIR}/FreeBSD:13:amd64/latest)

IMAGE_TARGET=disc1.iso
IMAGE_NAME=disc1.iso
IMAGE_EXT=.iso

POUDRIERE_DIR=`realpath poudriere-conf`

RELEASE_DIR=${MAKEOBJDIRPREFIX}/${FBSD_TREE}/amd64.amd64/release/

build_installer()
{
    sudo chflags -R noschg ${RELEASE_DIR}
    sudo rm -rf ${RELEASE_DIR}
    cd ${FBSD_TREE}/release && sudo -E make ${IMAGE_TARGET} WITH_PKGBASE=y REPODIR=${DYNFI_REPO} \
				    DYNFI_REPODIR=/usr/local/poudriere/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/ \
				    PORTSDIR=${POUDRIERE_DIR}/.. \
				    WITH_SERIAL=yes \
				    NODOC=

    mkdir -p ~/image/
    cp ${MAKEOBJDIRPREFIX}/${FBSD_TREE}/amd64.amd64/release/${IMAGE_NAME} ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}

    sudo chflags -R noschg ${RELEASE_DIR}
    sudo rm -rf ${RELEASE_DIR}
    cd ${FBSD_TREE}/release && sudo -E make ${IMAGE_TARGET} WITH_PKGBASE=y REPODIR=${DYNFI_REPO} \
				    DYNFI_REPODIR=/usr/local/poudriere/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/ \
				    PORTSDIR=${POUDRIERE_DIR}/.. \
				    NODOC=

    mkdir -p ~/image/
    cp ${RELEASE_DIR}/${IMAGE_NAME} ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}

    bzip2 -v -9 ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}
    bzip2 -v -9 ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}

    cat ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 | sha256 > ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256
    cat ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 | sha256 > ~/image/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256

    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2
    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2
    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256
    scp ~/image/dynfi_installer_serial_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/dynfi_installer_vga_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}.bz2.sha256
}

mkdir -p ${LOGS_DIR}

build_installer 2>&1 | tee -a ${LOGS_DIR}/build_installer.log
