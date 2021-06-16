#/bin/sh

git -C /home/builder/freebsd-ports pull

rm -r dynfi-overlay/dynfi/opnsense-core
rm -r dynfi-overlay/dynfi/opnsense-update
cp -iprv freebsd-ports/dynfi/opnsense-core dynfi-overlay/dynfi/opnsense-core
cp -iprv freebsd-ports/dynfi/opnsense-update dynfi-overlay/dynfi/opnsense-update
