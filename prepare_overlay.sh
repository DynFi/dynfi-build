#/bin/sh

. common.subr

git -C ${DYNFIWRKDIR}/freebsd-ports pull

rm -r dynfi-overlay/dynfi/opnsense-core
rm -r dynfi-overlay/dynfi/opnsense-update
cp -iprv freebsd-ports/dynfi/opnsense-core dynfi-overlay/dynfi/opnsense-core
cp -iprv freebsd-ports/dynfi/opnsense-update dynfi-overlay/dynfi/opnsense-update

sudo -E poudriere ports -c -m null -p dynfi-overlay -M `realpath dynfi-overlay`
