#!/bin/sh
set -e

CHANNEL=beta
PACKAGE_NAME=chromium-browser
WORK_DIR=$HOME/bzr/$PACKAGE_NAME.head.daily
CHROMIUM=$HOME/svn/$PACKAGE_NAME-$CHANNEL

cd "$WORK_DIR"
dpkg-architecture -c \
./debian/rules get-orig-source LOCAL_BRANCH=$CHROMIUM CHANNEL=$CHANNEL

tarball=$(ls $PACKAGE_NAME*.orig.tar.gz)
count=$(echo "$tarball" | wc -w)
if [ "$count" != 1 ]; then
	echo >&2 "Need 1 tarball, got $count"
	ls -lh >&2 $tarball
	exit 1
fi

ls -lh $tarball
chmod 644 $tarball
scp -pr $tarball carme.pld-linux.org:public_html/chromium-browser/src/$CHANNEL/

install -d archive/$CHANNEL
mv $tarball archive/$CHANNEL
