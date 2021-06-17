#!/bin/sh

. common.subr

CLEAN=n
RELEASE=n
CLEAN_FLAG=-DNO_CLEAN

usage()
{
    cat <<EOF
Usage: `basename $0` [options]
Options:
	-b	Git branch to use (default dynfi-13)
	-c	Reclone the git repository
	-r	Bootstrap a release (does make packages instead of update-packages)
	-h	This help
EOF
    exit 1
}

error()
{
    echo "$1"
    rm ${PID_FILE}
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
	cd ${FBSD_TREE}
    else
	cd ${FBSD_TREE}
	git pull
    fi

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

    echo ""
    echo "Syncing packages"
    echo ""
    rsync -avz -e "ssh -i $HOME/.ssh/pkg-sync-sshkey" --progress ${DYNFI_REPO}/FreeBSD:13:amd64 pkg@192.168.230.10:/var/www/html/base/
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


if [ -f ${PID_FILE} ]; then
    echo "A build is already in progress"
    exit 1
fi
echo $$ > ${PID_FILE}

mkdir -p ${LOGS_DIR}
build_base 2>&1 | tee -a ${LOGS_DIR}/build_freebsd.log
rm ${PID_FILE}
