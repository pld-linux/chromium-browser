#!/bin/sh
# Usage:
# ./update-source.sh
# env variables controlling behaviour
#  build_package=[0|1] - build package when new version is fetched
#  publish_packages=[0|1] - publish built packages in ~/public_html/$dist/$arch
#  quiet=[0|1] - discard stdout of process

pkg=chromium-browser
specfile=$pkg.spec

# work in package dir
dir=$(dirname "$0")
cd "$dir"

# abort on errors
set -e

# setup $quiet, you may override with env it
quiet=${quiet:-$(tty -s && echo 0 || echo 1)}
if [ "$quiet" = "1" ]; then
	# we do not want output when running on cron
	exec 1>/dev/null
fi

# take baseurl from .spec Source0
baseurl=$(awk '/^Source0:/{print $2}' $specfile | xargs dirname)

if [ "$1" ]; then
	url=$1
else
	if [ ! -x /usr/bin/lynx ]; then
		echo >&2 "${1##*/}: need lynx to parse sources"
		exit 1
	fi
	echo "Fetching latest tarball name..."
	urls=$(lynx -dump $baseurl/ | awk '/[0-9]+\. .*orig\.tar\.gz/{print $NF}')
	# unescape "~" encoded by lighttpd
	url=$(echo "$urls" | sed -e 's,%7e,~,gi' | sort -Vr | head -n1)
fi

if [ -z "$url" ]; then
	echo >&2 "URL empty..."
	exit 1
fi

tarball=${url##*/}
echo "tarball: $tarball..."

if [ ! -f $tarball ]; then
	if [ ! -x /usr/bin/wget ]; then
		echo >&2 "${1##*/}: need wget to fetch tarball"
		exit 1
	fi
	wget $(test "$quiet" = "1" && echo -q) -c $url
	upload=$tarball
fi


# cvs up specfile, rename in case of conflicts
cvs up $specfile || { set -x; mv -b $specfile $specfile.old && cvs up $specfile; }

svndate=$(awk '/^%define[ 	]+svndate[ 	]+/{print $NF}' $specfile)
svnver=$(awk '/^%define[ 	]+svnver[ 	]+/{print $NF}' $specfile)
version=$(awk '/^Version:[ 	]+/{print $NF}' $specfile)
rel=$(awk '/^%define[ 	]+rel[ 	]+/{print $NF}' $specfile)
if [ "$svndate" = "%{nil}" ]; then
	svndate=
fi

newtar=${pkg}_${version}~${svndate:+svn${svndate}}r${svnver}.orig.tar.gz
if [ "$newtar" = "$tarball" ]; then
	echo "$specfile already up to $newtar"

	# if we don't publish result, there's nothing more to do
	if [ "$publish_packages" != 1 ]; then
		exit 0
	fi
else
	echo "Updating $specfile to $tarball"
	part=${tarball#${pkg}_}
	version=${part%~*}; part=${part#*${version}~}
	release=1
	if [ "$part" != "${part%%svn*}" ]; then
		svndate=${part#svn*}; svndate=${svndate%%r*}
		part=${part#svn${svndate}}
	else
		svndate='%{nil}'
	fi
	svnver=${part#r}; svnver=${svnver%%.*}

	sed -i -e "
		s/^\(%define[ \t]\+svnver[ \t]\+\)[0-9]\+\$/\1$svnver/
		s/^\(%define[ \t]\+svndate[ \t]\+\).\+\$/\1$svndate/
		s/^\(%define[ \t]\+rel[ \t]\+\)[0-9]\+\$/\1$release/
		s/^\(Version:[ \t]\+\)[.0-9]\+\$/\1$version/
	" $specfile

	../builder -ncs -5 $specfile
fi

# if we don't build. we're done
if [ "$build_package" = 0 ]; then
	exit 0
fi

dist=$(rpm -E %{pld_release})
arch=$(rpm -E %{_host_cpu})
outdir=$(readlink -f $dir)/build-$dist-$arch
logfile=$outdir/$pkg.log
rpmdir=$outdir/RPMS
rpmdest=~/public_html/chromium-browser/$dist/$arch
install -d $rpmdir

# if already published?
if [ "$publish_packages" = 1 ]; then
	pkg=$rpmdest/$pkg-$version-0.$svnver.$rel.$arch.rpm
	if [ -f "$pkg" ]; then
		exit 0
	fi
fi

# setup custom logfile via $HOME_ETC hack
# TODO: just add --logfile support for builder
cat > $outdir/.builderrc <<-EOF
	if [ -n "$HOME_ETC" ]; then
		. "$HOME_ETC/.builderrc"
	elif [ -r ~/.builderrc ]; then
		. ~/.builderrc
	fi
	LOGFILE='$logfile'
EOF

> $logfile
HOME_ETC=$outdir \
	../builder -bb --clean \
	--define "_unpackaged_files_terminate_build 1" \
	--define '_enable_debug_packages 0' \
	--define "_builddir $outdir" \
	--define "_rpmdir $rpmdir" \
	$specfile || {
	echo >&2 "Package build failed"
	tail -n 1000 $logfile >&2
	exit 1
}

if [ "$publish_packages" ] && [ "$(ls $rpmdir/*.rpm 2>/dev/null)" ]; then
	install -d $rpmdest
	umask 022
	chmod 644 $rpmdir/*.rpm
	mv -v $rpmdir/*.rpm $rpmdest/
	poldek --cachedir=$HOME/tmp --mkidx -s $rpmdest/ --mt=pndir

	if [ -x /usr/bin/createrepo ]; then
		install -d $rpmdest/repodata/cache
		createrepo -q -c $rpmdest/repodata/cache $rpmdest
	fi
fi
