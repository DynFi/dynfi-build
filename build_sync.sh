#!/bin/sh

. common.subr

echo ""
echo "Syncing base"
echo ""
rsync -avz --progress ${DYNFI_REPO}/FreeBSD:14:amd64 ${PUBLIC_SRV}:/var/www/html/base-dev/

echo ""
echo "Syncing ports"
echo ""
rsync -avz --progress poudriere-base/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/.latest/* ${PUBLIC_SRV}:/var/www/html/packages3-dev/FreeBSD\:14/:amd64
