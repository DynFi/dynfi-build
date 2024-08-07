#!/bin/sh

. common.subr
. common_start.subr

DFF_VERSION=$(readlink ${DYNFI_REPO}/FreeBSD:14:amd64/latest)

IMAGE_TARGET=disc1.iso
IMAGE_NAME=disc1.iso
IMAGE_EXT=.iso

DYNFI_PKG_REPODIR="`realpath ${DYNFIWRKDIR}`/poudriere-base/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}"

RELEASE_DIR=${MAKEOBJDIRPREFIX}/${FBSD_TREE}/amd64.amd64/release/

create_ports_list() {
	ls ${DYNFI_PKG_REPODIR}/All | sed 's|^|All\/|'
}

image_name()
{

    echo "dynfi_installer_${1}_${DFF_VERSION}-${date}${IMAGE_SUFFIX}${IMAGE_EXT}"
}

build_installer()
{
    name=`image_name ${1}`
    shift
    opts="$@"

    sudo chflags -R noschg ${RELEASE_DIR}
    sudo rm -rf ${RELEASE_DIR}
    cd ${FBSD_TREE}/release && sudo -E make ${IMAGE_TARGET} WITH_PKGBASE=y REPODIR=${DYNFI_REPO} \
				    DYNFI_REPODIR=${DYNFI_PKG_REPODIR} \
				    PORTSDIR=${PORTSDIR} \
				    NODOC= ${opts}
    mkdir -p ${IMAGE_DIR}/
    cp ${MAKEOBJDIRPREFIX}/${FBSD_TREE}/amd64.amd64/release/${IMAGE_NAME} ${IMAGE_DIR}/${name}

    bzip2 -v -9 ${IMAGE_DIR}/${name}

    cat ${IMAGE_DIR}/${name}.bz2 | sha256 > ${IMAGE_DIR}/${name}.bz2.sha256
}

mkdir -p ${LOGS_DIR}

export DYNFI_PORTS_LIST=`create_ports_list`
if [ $? -ne 0 -o -z "${DYNFI_PORTS_LIST}" ]; then
	echo "The ports list is empty."
	exit 1
fi

build_installer serial "WITH_SERIAL=yes" 2>&1 | tee -a ${LOGS_DIR}/build_installer.log || exit 1
build_installer vga 2>&1 | tee -a ${LOGS_DIR}/build_installer.log || exit 1

echo "========== BUILD FINISHED ==========="
echo "Serial image:  `image_name serial`.bz2"
echo "Serial sha256: `image_name serial`.bz2.sha256"
echo "VGA image:     `image_name vga`.bz2"
echo "VGA sha256:    `image_name vga`.bz2.sha256"
echo "====================================="
