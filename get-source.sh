#!/bin/sh
set -e
set -x

# CHANNEL: any from CHANNELS_URL: beta, dev
CHANNEL=${1:-beta}

CHANNELS_URL=http://omahaproxy.appspot.com/
PACKAGE_NAME=chromium-browser
WORK_DIR=$HOME/bzr/$PACKAGE_NAME.head.daily
CHROMIUM=$HOME/svn/$PACKAGE_NAME-$CHANNEL
LOCKFILE=$WORK_DIR/$PACKAGE_NAME-$CHANNEL.lock

VERSION=$(wget -qO - "$CHANNELS_URL?os=linux&channel=$CHANNEL" | awk -F, 'NR > 1{print $3}')
VERSION_FILE=$WORK_DIR/archive/$CHANNEL/${PACKAGE_NAME}_$VERSION~*.tar.gz

if [ -e $VERSION_FILE ]; then
	# nothing to update
	exit 0
fi

# consider lockfile stale after 3h
if ! lockfile -l 10800 $LOCKFILE; then
	exit 1
fi

trap "rm -f $LOCKFILE" EXIT

LOGFILE=$(mktemp $WORK_DIR/$PACKAGE_NAME-$CHANNEL.XXXXXX)

cd "$WORK_DIR"
dpkg-architecture -c \
./debian/rules get-orig-source LOCAL_BRANCH=$CHROMIUM CHANNEL=$CHANNEL USE_GREEN_REV=1 > $LOGFILE 2>&1 </dev/null

tarball=$(ls $PACKAGE_NAME*.orig.tar.gz)
count=$(echo "$tarball" | wc -w)
if [ "$count" != 1 ]; then
	echo >&2 "Need 1 tarball, got $count"
	ls -lh >&2 $tarball
	exit 1
fi

logfile=$(basename $tarball .orig.tar.gz).log
mv $LOGFILE $logfile

ls -lh $tarball $logfile
chmod 644 $tarball $logfile
scp -pr $logfile $tarball carme.pld-linux.org:public_html/chromium-browser/src/$CHANNEL/

install -d archive/$CHANNEL
mv $logfile $tarball archive/$CHANNEL
