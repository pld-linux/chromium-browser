#!/bin/sh
set -e

# CHANNEL: any from CHANNELS_URL: stable, beta, dev
CHANNEL=${1:-beta}

CHANNELS_URL=http://omahaproxy.appspot.com/all
PACKAGE_NAME=chromium-browser
WORK_DIR=$(cd $(dirname "$0"); pwd)
CHROMIUM=$HOME/svn/$PACKAGE_NAME-$CHANNEL
LOCKFILE=$WORK_DIR/$PACKAGE_NAME-$CHANNEL.lock
OFFICIAL_URL=http://commondatastorage.googleapis.com/chromium-browser-official
DIST_DIR=$HOME/public_html/chromium-browser/src/$CHANNEL

VERSION=$(wget -qO - "$CHANNELS_URL?os=linux&channel=$CHANNEL" | awk -F, 'NR > 1{print $3}')
if [ -z "$VERSION" ]; then
	echo >&2 "Can't figure out version for $CHANNEL"
	exit 1
fi

# don't use .xz for beta channels, annooying if unpacks that slowly
if [ "$CHANNEL" = "stable" ]; then
	EXT=xz
else
	EXT=gz
fi
VERSION_FILE=$DIST_DIR/$PACKAGE_NAME-$VERSION.tar.$EXT

if [ -e $VERSION_FILE -a -z "$FORCE" ]; then
	# nothing to update
	exit 0
fi

set -x

# consider lockfile stale after 3h
if ! lockfile -l 10800 $LOCKFILE; then
	exit 1
fi

trap "rm -f $LOCKFILE" EXIT

TMP_DIR=$(mktemp -d $WORK_DIR/$PACKAGE_NAME-$CHANNEL-$VERSION-_XXXXXX)
LOGFILE=$TMP_DIR/$PACKAGE_NAME-$VERSION.log

(
cd "$TMP_DIR"
srctarball=$PACKAGE_NAME-$VERSION.tar.bz2
wget -c -O $srctarball "$OFFICIAL_URL/chromium-$VERSION.tar.bz2"

# repackage cleaned up tarball
test -d $PACKAGE_NAME-$VERSION || {
	tar xjf $srctarball
	install -d $PACKAGE_NAME-$VERSION
	# relocate to src dir (needed  to workaround some gyp bug)
	mv chromium-$VERSION $PACKAGE_NAME-$VERSION/src
}

ls -lh $srctarball
rm $srctarball

cd $PACKAGE_NAME-$VERSION/src
du -sh .

awk 'NR=1 {print $NF; exit}' v8/ChangeLog | tee -a v8.txt

# keep v8 in sources if branch is not stable
if [ "$CHANNEL" = "stable" ]; then
	v8=0
else
	v8=0
fi

sh -x $WORK_DIR/clean-source.sh v8=$v8 libxml=0 zlib=0
du -sh .

# add LASTCHANGE info, take "branch_revision" item
svnver=$(wget -qO - "$CHANNELS_URL?os=linux&channel=$CHANNEL" | awk -F, 'NR > 1{print $8}')
echo "$svnver" > build/LASTCHANGE.in

cd ../..

tarball=$PACKAGE_NAME-$VERSION.tar.$EXT
XZ_OPT=-9 tar -cf $tarball --$EXT $PACKAGE_NAME-$VERSION
ls -lh $tarball

rm -rf $PACKAGE_NAME-$VERSION

chmod 644 $tarball
mv $tarball $DIST_DIR

) > $LOGFILE 2>&1

chmod 644 $LOGFILE
mv $LOGFILE $DIST_DIR

rm -rf $TMP_DIR

# create diff patches
BASEVER=${VERSION%.*}.0
if [ -e $DIST_DIR/$PACKAGE_NAME-$BASEVER.tar.$EXT ]; then
	base=$(readlink -f $DIST_DIR/$PACKAGE_NAME-$BASEVER.tar.$EXT)
	current=$DIST_DIR/$PACKAGE_NAME-$VERSION.tar.$EXT
	sh -x $WORK_DIR/make-diff-patch.sh $base $current
	mv $PACKAGE_NAME-$VERSION.patch.$EXT $DIST_DIR
fi

# try updating spec and build it as well
if [ -x $WORK_DIR/update-source.sh ]; then
	build_package=1 \
	publish_packages=1 \
	sh -x $WORK_DIR/update-source.sh
fi
