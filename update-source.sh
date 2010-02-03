#!/bin/sh
# work in package dir
dir=$(dirname "$0")
cd "$dir"

# abort on errors
set -e

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
	wget -c $url
	upload=$tarball
fi

if [ -z "$skip_distfiles" ] && [ "$upload" ] && [ -x /usr/bin/lftp ]; then
	echo "Uploading to dropin. ^C to abort"
	../dropin $upload
fi

pkg=chromium-browser
specfile=$pkg.spec

svndate=$(awk '/^%define[ 	]+svndate[ 	]+/{print $NF}' $specfile)
svnver=$(awk '/^%define[ 	]+svnver[ 	]+/{print $NF}' $specfile)
version=$(awk '/^Version:[ 	]+/{print $NF}' $specfile)
rel=$(awk '/^%define[ 	]+rel[ 	]+/{print $NF}' $specfile)

newtar=${pkg}_${version}~svn${svndate}r${svnver}.orig.tar.gz
if [ "$newtar" != "$tarball" ]; then
	echo "Updating $specfile $to $newtar"
	version=${tarball#${pkg}_} version=${version%~*}
	svndate=${tarball#*svn} svndate=${svndate%%r*}
	svnver=${tarball#${pkg}_${version}~svn${svndate}r} svnver=${svnver%%.*}

	sed -i -e "
		s/^\(%define[ \t]\+svnver[ \t]\+\)[0-9]\+\$/\1$svnver/
		s/^\(%define[ \t]\+svndate[ \t]\+\)[0-9]\+\$/\1$svndate/
		s/^\(Version:[ \t]\+\)[.0-9]\+\$/\1$version/
	" $specfile
	../builder -ncs -5 $specfile

	if [ "$build_package" ]; then
		dist=$(rpm -E %{pld_release})
		arch=$(rpm -E %{_host_cpu})
		outdir=$(readlink -f $dir)/build-$dist-$arch
		rpmdir=$outdir/RPMS
		install -d $rpmdir

		../builder -bb --clean --define '_enable_debug_packages 0' --define "_builddir $outdir" --define "_rpmdir $rpmdir" $specfile

		rpmdest=~/public_html/$dist/$arch/
		if [ "$publish_packages" ] && [ "$(ls $rpmdir/*.rpm 2>/dev/null)" ]; then
			install -d $rpmdest
			umask 022
			chmod 644 $rpmdir/*.rpm
			mv -v $rpmdir/*.rpm $rpmdest/
			poldek --cachedir=$HOME/tmp --mkidx -s $rpmdest/ --mt=pndir
		fi
	fi
else
	echo "$specfile already up to $newtar"
fi
