#!/bin/sh

# based on debian/rules for chromium-browser package

set -e
set -x

CHANNEL="beta"
# See Staying Green More Of The Time at http://dev.chromium.org/developers/how-tos/get-the-code
USE_GREEN_REV=1

GCLIENT_URL="http://src.chromium.org/svn/trunk/tools/depot_tools"
CHROMIUM_URL="http://src.chromium.org/svn/trunk/src"
CHROMIUM_RLZ="http://src.chromium.org/svn/releases"
DEPS_URL="http://src.chromium.org/svn/trunk/deps/third_party"
GREEN_REV_URL="http://chromium-status.appspot.com/lkgr"
CHANNELS_URL="http://omahaproxy.appspot.com/"

CHANNEL="beta"

# local mirror of chromium checkout,
# if empty code will be checked out each time
LOCAL_BRANCH=$(pwd)/chromium-browser

TMP_DDIR=$(pwd)/chromium-browser-$$
TMP_DIR=${LOCAL_BRANCH:-${TMP_DDIR}}

VERSION=$(wget -qO - "$CHANNELS_URL" | grep -i "^linux,${CHANNEL}" | cut -d, -f3)

if [ -z "$LOCAL_BRANCH" ]; then
	rm -rf $TMP_DIR
fi

install -d $TMP_DIR

if [ ! -d $TMP_DIR/tools/depot_tools ] ; then \
	svn co "$GCLIENT_URL" $TMP_DIR/tools/depot_tools
else
	svn update $TMP_DIR/tools/depot_tools
fi

cd $TMP_DIR
if [ "$USE_GREEN_REV" -eq 1 ]; then
	REVISION=$(wget -qO - "${GREEN_REV_URL}")
	./tools/depot_tools/gclient config "${CHROMIUM_URL}" "${GREEN_REV_URL}"
else
	REVISION=101024
	./tools/depot_tools/gclient config "${CHROMIUM_URL}"
fi

REVISION="--revision src@${REVISION}"

cd $TMP_DIR
./tools/depot_tools/gclient update --nohooks ${REVISION}

cd $TMP_DIR
SDIR=`grep '"name"' .gclient | cut -d\" -f4`
perl -i~ -pe 's%(.python., .src/build/gyp_chromium.)%"echo", "#disabled#", $1%' $SDIR/DEPS
./tools/depot_tools/gclient runhooks
mv $SDIR/DEPS~ $SDIR/DEPS

if [ -n "$LOCAL_BRANCH" ]; then
	rm -rf $TMP_DDIR
	cp -la $TMP_DIR $TMP_DDIR
fi

cd $TMP_DDIR/src && find . -type f \( -iname \*.exe -o -iname \*.dll -o -iname \*.pdb -o -name \*.o -o -name \*.a -o -name \*.dylib \) -exec rm -fv {} \; > REMOVED-bin_only.txt
wc -l $TMP_DDIR/src/REMOVED-*.txt

TMP_DIR=$TMP_DDIR
