#!/bin/sh

. common.subr

read -p 'This will change production are you sure? [N/y] ' q
if [ $q != 'y' ]; then
	echo "Good decision!"
	return 0
fi

echo ""
echo "Syncing base"
echo ""
rsync -avz --progress ${DYNFI_REPO}/FreeBSD:13:amd64 ${PUBLIC_SRV}:/var/www/html/base/

echo ""
echo "Syncing ports"
echo ""
rsync -avz --progress poudriere-base/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/.latest/* ${PUBLIC_SRV}:/var/www/html/packages2/FreeBSD\:13\:amd64
