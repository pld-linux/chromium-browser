#!/bin/sh
# Create .patch based on $1 for $2
src=$1
dst=$2
ext=.tar.xz

set -e

srcdir=$(basename $src $ext)
dstdir=$(basename $dst $ext)
patch=$dstdir.patch

test -d $srcdir || unpack $src
test -d $dstdir || unpack $dst
if diff -Nur $srcdir $dstdir > $patch; then
	echo "No diffs!"
else
	echo "Patch created"
	ls -lh $patch
	diffstat $patch | tee $patch.diff
	cat $patch.diff $patch | xz -9 > $patch.xz
fi

rm -rf $dstdir $srcdir
