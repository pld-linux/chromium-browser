#!/bin/sh
# Usage:
# ./update-source.sh
# env variables controlling behaviour
#  build_package=[0|1] - build package when new version is fetched
#  prep_package=[0|1] - check if package can be unpacked (implies build_package)
#  publish_packages=[0|1] - publish built packages in ~/public_html/$dist/$arch
#  quiet=[0|1] - discard stdout of process

test "$prep_package" = 0 && build_package=0

pkg=chromium-browser
specfile=$pkg.spec

# work in package dir
dir=$(dirname "$0")
cd "$dir"

# extract version components from url
# exports: $version; $release; $svndate; $svnver
extract_version() {
	set -x
	local url=$1 part

	part=${url#${pkg}[_-]}
	if [[ $version = *~* ]]; then
		# ubuntu urls
		version=${part%~*}; part=${part#*${version}~}
	else
		version=${part%.tar.xz}; part=${part#*${version}.tar.xz}
	fi

	# release always 1 :)
	release=1
	if [ "$part" != "${part%%svn*}" ]; then
		svndate=${part#svn*}; svndate=${svndate%%r*}
		part=${part#svn${svndate}}
	else
		svndate='%{nil}'
	fi
	svnver=${part#r}; svnver=${svnver%%.*}
}

url2version() {
	local url=$1

	echo "${url}" | sed -e "
		s,$version,%{version},g
		s,$release,%{release},g
		s,$svndate,%{svndate},g
		s,$svnver,%{svnver},g
	"
}

# setup url from template
version2url() {
	local url=$1

	echo "${url}" | sed -e "
		s,%{version},$version,g
		s,%{release},$release,g
		s,%{svndate},$svndate,g
		s,%{svnver},$svnver,g
	"
}

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
	urls=$(lynx -width 200 -dump $baseurl/ | awk '/[0-9]+\. .*\.tar/{print $NF}')
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
fi

extract_version $tarball
url_tpl=$(url2version $tarball)

svndate=$(awk '/^%define[ 	]+svndate[ 	]+/{print $NF}' $specfile)
svnver=$(awk '/^%define[ 	]+svnver[ 	]+/{print $NF}' $specfile)
version=$(awk '/^Version:[ 	]+/{print $NF}' $specfile)
rel=$(awk '/^%define[ 	]+rel[ 	]+/{print $NF}' $specfile)
if [ "$svndate" = "%{nil}" ]; then
	svndate=
fi

newtar=$(version2url $url_tpl)

if [ "$newtar" = "$tarball" ]; then
	echo "$specfile already up to $newtar"

	# if we don't publish result, there's nothing more to do
	if [ "$publish_packages" != 1 ]; then
		exit 0
	fi
else
	echo "Updating $specfile to $tarball"
	extract_version $tarball

	sed -i -e "
		s/^\(%define[ \t]\+svnver[ \t]\+\)[0-9]\+\$/\1$svnver/
		s/^\(%define[ \t]\+svndate[ \t]\+\).\+\$/\1$svndate/
		s/^\(%define[ \t]\+rel[ \t]\+\)[0-9]\+\$/\1$release/
		s/^\(Version:[ \t]\+\)[.0-9]\+\$/\1$version/
	" $specfile

	../builder -ncs -5 $specfile
fi

# if we don't build. we're done
if [ "$prep_package" = 0 ]; then
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
	pkg=$rpmdest/$pkg-$version-${svnver:+0.$svnver.}$release.$arch.rpm
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

command=-bp
test "$build_package" = 1 && command=-bb
> $logfile
HOME_ETC=$outdir \
	../builder $command --clean \
	--define "_unpackaged_files_terminate_build 1" \
	--define '_enable_debug_packages 0' \
	--define "_builddir $outdir" \
	--define "_rpmdir $rpmdir" \
	$specfile || {
	echo >&2 "Package build failed"
	tail -n 1000 $logfile >&2
	exit 1
}

if [ "$publish_packages" = 1 ] && [ "$(ls $rpmdir/*.rpm 2>/dev/null)" ]; then
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
