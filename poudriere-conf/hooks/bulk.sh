#!/bin/sh

if [ "$1" != "done" ]; then
    exit 0
fi

rsync -avz -e "ssh -i /root/pkg-sync-sshkey" --progress /usr/local/poudriere/data/packages/dynfi-13-default/.latest/* pkg@192.168.230.10:/var/www/html/packages/FreeBSD\:13\:amd64
