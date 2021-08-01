#!/bin/sh

BASEDIR=$(dirname "$0")

read -t 2 sum
[ -z "$sum" ] && exit 1

echo SIGNATURE
echo -n $sum | /usr/bin/openssl dgst -sign ${BASEDIR}/keys/pkg-dff.key -sha256 -binary
echo
echo CERT
cat ${BASEDIR}/keys/pkg-dff.pub
echo END
