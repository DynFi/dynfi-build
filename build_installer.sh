#!/bin/sh

. common.subr
. common_start.subr

DFF_VERSION=$(readlink ${DYNFI_REPO}/FreeBSD:13:amd64/latest)

IMAGE_TARGET=disc1.iso
IMAGE_NAME=disc1.iso
IMAGE_EXT=.iso

POUDRIERE_DIR="`realpath freebsd-ports`"
DYNFI_PKG_REPODIR="`realpath ${DYNFIWRKDIR}`/poudriere-base/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}"

RELEASE_DIR=${MAKEOBJDIRPREFIX}/${FBSD_TREE}/amd64.amd64/release/

build_installer()
{
    name="dynfi_installer_${1}_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}"
    shift
    opts="$@"

    sudo chflags -R noschg ${RELEASE_DIR}
    sudo rm -rf ${RELEASE_DIR}
    cd ${FBSD_TREE}/release && sudo -E make ${IMAGE_TARGET} WITH_PKGBASE=y REPODIR=${DYNFI_REPO} \
				    PKG_REPO_SIGNING_KEY=${DYNFI_SIGNKEY} \
				    DYNFI_REPODIR=${DYNFI_PKG_REPODIR} \
				    PORTSDIR=${PORTSDIR} \
				    NODOC= ${opts}

    mkdir -p ~/image/
    cp ${MAKEOBJDIRPREFIX}/${FBSD_TREE}/amd64.amd64/release/${IMAGE_NAME} ~/image/${name}

    bzip2 -v -9 ~/image/${name}

    cat ~/image/${name}.bz2 | sha256 > ~/image/${name}.bz2.sha256

    scp ~/image/${name}.bz2 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/
    scp ~/image/${name}.bz2.sha256 publisher@dynfi.com:/var/www/dynfi/sites/default/files/dff/
}

mkdir -p ${LOGS_DIR}

build_installer serial "WITH_SERIAL=yes" 2>&1 | tee -a ${LOGS_DIR}/build_installer.log
build_installer vga 2>&1 | tee -a ${LOGS_DIR}/build_installer.log
