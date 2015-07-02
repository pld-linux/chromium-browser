#!/bin/sh
set -e

# CHANNEL: any from CHANNELS_URL: stable, beta, dev
CHANNEL=${1:-beta}

CHANNELS_URL=https://omahaproxy.appspot.com/all
PACKAGE_NAME=chromium-browser
PROGRAM=${0##*/}
WORK_DIR=$(cd "$(dirname "$0")"; pwd)
LOCKFILE=$WORK_DIR/$PACKAGE_NAME-$CHANNEL.lock
# Browse URL: https://gsdview.appspot.com/chromium-browser-official/
OFFICIAL_URL=https://commondatastorage.googleapis.com/chromium-browser-official
ALT_URL=https://github.com/zcbenz/chromium-source-tarball/releases/download
DIST_DIR=$HOME/public_html/chromium-browser/src/$CHANNEL

# skip package build if interactive
tty -s && build_package=0

VERSION=${2:-$(wget -qO - "$CHANNELS_URL?os=linux&channel=$CHANNEL" | awk -F, 'NR > 1{print $3}')}
if [ -z "$VERSION" ]; then
	echo >&2 "Can't figure out version for $CHANNEL"
	exit 1
fi

# don't use .xz for beta channels, annoying if unpacks that slowly
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

(
	flock -n 9 || { echo "$PROGRAM: locked"; exit 1; }

	TMP_DIR=$(mktemp -d $WORK_DIR/$PACKAGE_NAME-$CHANNEL-$VERSION-_XXXXXX)
	LOGFILE=$TMP_DIR/$PACKAGE_NAME-$VERSION.log

	(
	cd "$TMP_DIR"
	srctarball=$PACKAGE_NAME-$VERSION.tar.xz

	wget -nc -nv -O $srctarball "$OFFICIAL_URL/chromium-$VERSION.tar.xz" || :
	test -s $srctarball || rm $srctarball

	wget -nc -nv -O $srctarball "$ALT_URL/$VERSION/chromium-$VERSION.tar.xz" || :
	test -s $srctarball || rm $srctarball

	test -f $srctarball

	# repackage cleaned up tarball
	test -d $PACKAGE_NAME-$VERSION || {
		tar xvf $srctarball
		mv chromium-$VERSION $PACKAGE_NAME-$VERSION
	}

	ls -lh $srctarball
	rm $srctarball

	cd $PACKAGE_NAME-$VERSION
	du -sh .

	awk '/^#define/ && /(MAJOR|MINOR)_VERSION|BUILD_NUMBER|PATCH_LEVEL/ { printf("%s=%s\n", $2, $3) }' v8/src/version.cc | tee -a v8.sh

	if [ "$CHANNEL" = "stable" ]; then
		patch -p1 < $WORK_DIR/remove_bundled_libraries-stale.patch
		sh -x $WORK_DIR/clean-source.sh emptydirs=1 v8=0 mesa=0 sqlite=0 ffmpeg=0 protobuf=0
		patch -p1 -R < $WORK_DIR/remove_bundled_libraries-stale.patch
	fi

	# do not keep REMOVED*.txt in tarball. they are visible in .log anyway
	rm -vf REMOVED-*.txt

	du -sh .

	# add LASTCHANGE info, take "branch_revision" item
	svnver=$(wget -qO - "$CHANNELS_URL?os=linux&channel=$CHANNEL" | awk -F, 'NR > 1{print $8}')
	echo "$svnver" > build/LASTCHANGE.in

	cd ..

	tarball=$PACKAGE_NAME-$VERSION.tar.$EXT
	# xz -9 OOM's on carme
	XZ_OPT=-e8 tar -caf $tarball $PACKAGE_NAME-$VERSION
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
		if [ "$(basename $base)" != "$(basename $current)" ]; then
			sh -x $WORK_DIR/make-diff-patch.sh $base $current
			chmod 644 $PACKAGE_NAME-$VERSION.patch.xz
			mv $PACKAGE_NAME-$VERSION.patch.xz $DIST_DIR
			# for beta and dev channels, update the diff pointer
			if [ "$CHANNEL" != "stable" ]; then
				ln -sf $PACKAGE_NAME-$VERSION.tar.$EXT $DIST_DIR/$PACKAGE_NAME-$BASEVER.tar.$EXT
			fi
		fi
	fi

	# try updating spec and build it as well
	if [ -x $WORK_DIR/update-source.sh ]; then
		build_package=${build_package-1} \
		publish_packages=${publish_packages-1} \
		sh -x $WORK_DIR/update-source.sh
	fi

	rm $LOCKFILE
) 9>$LOCKFILE
