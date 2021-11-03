#!/bin/sh

CLEAN=n

. common.subr

# Either empty or -c for a clean bulk
PORT_BULK=

PORTS_FILE="`realpath PORTS_LIST`"

usage()
{
    cat <<EOF
Usage: `basename $0` [options]
Options:
	-b	Git branch for the jail (default: dynfi-13-stable)
	-o	Ports tree to use for the overlays (default: dynfi-overlay)
	-p	Git branch for the portstree (default: default)
	-c	Recreate the jail
EOF
    exit 1
}

error()
{
    echo "$1"
    exit 1
}

build_jail()
{
    # Build poudriere jail and poudriere package
    # We need to always rebuild the jail so the userland/kernelland used for compiling
    # packages is the same as the one we will run
    if [ "${CLEAN}" == "y" ]; then
	echo ""
	echo "Building the poudriere jail"
	echo ""
	yes | sudo -E poudriere jail -d -j ${FBSD_BRANCH}
	sudo -E poudriere jail -c -j ${FBSD_BRANCH} -b -m src="${FBSD_TREE}" -v ${FBSD_BRANCH} || error "Poudriere: jail compile failed"
    fi
}

build_packages()
{
    echo ""
    echo "Updating the ports tree"
    echo ""
    sudo -E poudriere ports -u -p ${PORT_BRANCH} || error "Poudriere: ports update failed"

    echo ""
    echo "Building the packages using branch ${PORT_BRANCH}"
    echo ""
    sudo -E poudriere bulk ${PORT_BULK} -j ${FBSD_BRANCH} -p ${PORT_BRANCH} -O ${OVERLAY_PORTS} -f "${PORTS_FILE}" || error "Poudriere: bulk failed"
}

while [ $# -ne 0 ]; do
    case "$1" in
	-c)
	    CLEAN=y
	    PORT_BULK=-c
	    ;;
	-b)
	    shift
	    FBSD_BRANCH=$1
	    shift
	    ;;
	-o)
	    shift
	    OVERLAY_PORTS=$1
	    shift
	    ;;
	-p)
	    shift
	    PORT_BRANCH=$1
	    shift
	    ;;
	-h)
	    usage
	    ;;
    esac
    shift
done

. common_start.subr

mkdir -p ${LOGS_DIR}
build_jail 2>&1 | tee -a ${LOGS_DIR}/build_jail.log
build_packages 2>&1 | tee -a ${LOGS_DIR}build_packages.log
