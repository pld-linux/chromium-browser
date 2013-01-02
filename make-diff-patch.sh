#!/bin/sh
# Create .patch based on $1 for $2
src=$1
dst=$2
ext=.tar.xz

unpack() {
	case "$1" in
		*.tgz|*.tar.[Zz]|*.tar.gz) tar zx${verbose:+v}f "$1" ;;
		*.tar) tar x${verbose:+v}f "$1" ;;
		*.tbz2|*.tbz|*.tar.bz2) tar jx${verbose:+v}f "$1" ;;
		*.tar.xz) xz -dc "$1" | tar x${verbose:+v} ;;
		*.tar) tar x${verbose:+v}f "$1" ;;
		*)
			 echo >&2 "Don't know how to unpack $1"
			 return 1
		;;
	esac
}

# unpack all sources in commandline
for a in "$@"; do
	unpack "$a"
done

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
