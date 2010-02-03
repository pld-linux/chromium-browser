#!/bin/sh
baseurl=http://ppa.launchpad.net/chromium-daily/ppa/ubuntu/pool/main/c/chromium-browser

if [ "$1" ]; then
	url=$1
else
	if [ ! -x /usr/bin/lynx ]; then
		echo >&2 "${1##*/}: need lynx to parse sources"
		exit 1
	fi
	echo "Fetching latest tarball name..."
	url=$(lynx -dump $baseurl/ | awk '/orig\.tar\.gz/{tarball=$NF} END{print tarball}')
fi

tarball=${url##*/}
echo "tarball: $tarball..."

if [ ! -f $tarball ]; then
	if [ ! -x /usr/bin/wget ]; then
		echo >&2 "${1##*/}: need wget to fetch tarball"
		exit 1
	fi
	wget -c $tarball
	upload=$tarball
fi

if [ "$upload" ] && [ -x /usr/bin/lftp ]; then
	echo "Uploading to dropin. ^C to abort"
	../dropin $upload
fi

pkg=chromium-browser
specfile=$pkg.spec

svndate=$(awk '/^%define[ 	]+svndate[ 	]+/{print $NF}' $specfile)
svnver=$(awk '/^%define[ 	]+svnver[ 	]+/{print $NF}' $specfile)
version=$(awk '/^Version:[ 	]+/{print $NF}' $specfile)

newtar=${pkg}_${version}~svn${svndate}r${svnver}.orig.tar.gz
if [ "$newtar" != "$tarball" ]; then
	echo "Updating $specfile $to $newtar"
	version=${tarball#${pkg}_} version=${version%~*}
	svndate=${tarball#*svn} svndate=${svndate%%r*}
	svnver=${tarball#${pkg}_${version}~svn${svndate}r} svnver=${svnver%%.*}

	sed -i -e "
		s/^\(%define[ \t]\+svnver[ \t]\+\)[0-9]\+\$/\1$svnver/
		s/^\(%define[ \t]\+svndate[ \t]\+\)[0-9]\+\$/\1$svndate/
		s/^\(Version[ \t]\+\)[0-9]\+\$/\1$version/
	" $specfile
	../builder -ncs -5 $specfile
else
	echo "$specfile already up to $newtar"
fi
