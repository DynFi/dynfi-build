#!/bin/sh

. common.subr

echo ""
echo "Syncing base"
echo ""
rsync -avz -e "ssh -i $HOME/.ssh/pkg-sync-sshkey" --progress ${DYNFI_REPO}/FreeBSD:13:amd64 pkg@192.168.230.10:/var/www/html/base/

echo ""
echo "Syncing ports"
echo ""
rsync -avz -e "ssh -i $HOME/.ssh/pkg-sync-sshkey" --progress /usr/local/poudriere/data/packages/dynfi-13-default/.latest/* pkg@192.168.230.10:/var/www/html/packages/FreeBSD\:13\:amd64
