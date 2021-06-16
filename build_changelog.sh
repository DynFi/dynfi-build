#!/bin/sh

CHANGELOG_DIR=dff-changelog
CUR_DIR=$(pwd)

git -C ${CHANGELOG_DIR} pull

cd ${CHANGELOG_DIR}
make clean
make set

cd ${CUR_DIR}
sudo rsync -avz -e "ssh -i /root/pkg-sync-sshkey" --progress /home/builder/${CHANGELOG_DIR}/changelog.txz pkg@192.168.230.10:/var/www/html/packages/FreeBSD\:13\:amd64
