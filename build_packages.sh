#!/bin/sh

CLEAN=n


# Either empty or -c for a clean bulk
PORT_BULK=
PORT_BRANCH=default
FBSD_BRANCH=dynfi-13
OVERLAY_PORTS=dynfi-overlay

PORT_LIST="dynfi/opnsense-core lang/python3 net/aquantia-atlantic-kmod www/phalcon security/autossh"

usage()
{
    cat <<EOF
Usage: `basename $0` [options]
Options:
	-b	Git branch for the jail (default: dynfi-13)
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
	yes | sudo poudriere jail -d -j ${FBSD_BRANCH}
	sudo poudriere jail -c -j ${FBSD_BRANCH} -m git -U http://192.168.99.219/gitmob/freebsd/ -v ${FBSD_BRANCH} || error "Poudriere: jail compile failed"
    fi
}

build_packages()
{
    echo ""
    echo "Updating the ports tree"
    echo ""
    sudo poudriere ports -u -p ${PORT_BRANCH} || error "Poudriere: ports update failed"

    echo ""
    echo "Building the packages using branch ${PORT_BRANCH}"
    echo ""
    sudo poudriere bulk ${PORT_BULK} -j ${FBSD_BRANCH} -p ${PORT_BRANCH} -O ${OVERLAY_PORTS} ${PORT_LIST} || error "Poudriere: bulk failed"
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

if [ -f /tmp/build-dynfi.pid ]; then
    echo "A build is already in progress"
    exit 1
fi
echo $$ > /tmp/build-dynfi.pid

date=$(date "+%Y%m%d-%H%M%S")

mkdir -p /tmp/builder_logs_${date}

build_jail 2>&1 | tee -a /tmp/builder_logs_${date}/build_jail.log
build_packages 2>&1 | tee -a /tmp/builder_logs_${date}/build_packages.log

rm /tmp/build-dynfi.pid
