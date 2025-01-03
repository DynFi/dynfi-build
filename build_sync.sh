#!/bin/sh

. common.subr

echo ""
echo "Syncing base"
echo ""
rsync -avz --progress ${DYNFI_REPO}/FreeBSD:14:amd64 ${PUBLIC_SRV}:/var/www/html/base-dev/

if [ -f "enterprise/sync_enterprise.sh" ]; then
	./enterprise/sync_enterprise.sh
fi

echo ""
echo "Syncing ports"
echo ""
rsync -avz --progress poudriere-base/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/.latest/* ${PUBLIC_SRV}:/var/www/html/packages2-dev/FreeBSD\:14\:amd64
