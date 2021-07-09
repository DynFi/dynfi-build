#!/bin/sh

. common.subr

echo ""
echo "Syncing base"
echo ""
rsync -avz -e "ssh -i $HOME/.ssh/pkg-sync-sshkey" --progress ${DYNFI_REPO}/FreeBSD:13:amd64 pkg@192.168.230.10:/var/www/html/base/

echo ""
echo "Syncing ports"
echo ""
rsync -avz -e "ssh -i $HOME/.ssh/pkg-sync-sshkey" --progress poudriere-base/data/packages/${FBSD_BRANCH}-${PORT_BRANCH}/.latest/* pkg@192.168.230.10:/var/www/html/packages/FreeBSD\:13\:amd64
