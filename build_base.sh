#!/bin/sh

. common.subr

CLEAN=n
RELEASE=n
CLEAN_FLAG=-DNO_CLEAN

export PKG_REPO_SIGNING_KEY="signing_command: sh `realpath ./sign.sh`"

usage()
{
    cat <<EOF
Usage: `basename $0` [options]
Options:
	-b	Git branch to use (default dynfi-13-stable)
	-c	Reclone the git repository
	-r	Bootstrap a release (does make packages instead of update-packages)
	-h	This help
EOF
    exit 1
}

error()
{
    echo "$1"
    exit 1
}

build_base()
{
    if [ "${CLEAN}" == "y" ]; then
	echo ""
	echo "Cloning the FreeBSD source tree using branch ${FBSD_BRANCH}"
	echo ""
	rm -rf ${FBSD_TREE}
	git clone --depth=1 -b ${FBSD_BRANCH} ssh://git@192.168.99.219/freebsd.git ${FBSD_TREE}
    else
	git pull
    fi

    cd ${FBSD_TREE}

    echo ""
    echo "Building world and kernel"
    echo ""
    make -s buildworld -j${NCPUS} ${CLEAN_FLAG} || error "make buildworld failed"
    make -s buildkernel -j${NCPUS} ${CLEAN_FLAG} || error "make buildkernel failed"

    echo ""
    echo "Building packages"
    echo ""
    if [ "${RELEASE}" = "y" ]; then
	make -s packages -j${NCPUS} REPODIR=${DYNFI_REPO} || error "make packages failed"
    else
	make -s update-packages -j${NCPUS} REPODIR=${DYNFI_REPO} || error "make update-packages failed"
    fi

}

while [ $# -ne 0 ]; do
    case "$1" in
	-c)
	    CLEAN=y
	    CLEAN_FLAG=
	    ;;
	-r)
	    RELEASE=y
	    ;;
	-b)
	    shift
	    FBSD_BRANCH=$1
	    shift
	    ;;
	-h|*)
	    usage
	    ;;
    esac
    shift
done

. common_start.subr

mkdir -p ${LOGS_DIR}
build_base 2>&1 | tee -a ${LOGS_DIR}/build_freebsd.log
