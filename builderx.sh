#!/bin/sh
# Some notes:
# https://code.google.com/p/chromium/wiki/LinuxFasterBuilds
set -x

dir=$(dirname "$0")
dir=$(cd "$dir"; pwd)
outdir=$dir/BUILD
rpmdir=$dir/RPMS
logs=$outdir/logs

export CCACHE_DIR=$outdir/ccache
export CCACHE_LOGFILE=$CCACHE_DIR/log
export CCACHE_NLEVELS=1
export CCACHE_HARDLINK=1
#export CCACHE_BASEDIR
#export CCACHE_SLOPPINESS=include_file_mtime

install -d $outdir $rpmdir $logs

# init ccache with unlimited size (it's default is 1G)
if [ ! -d "$CCACHE_DIR" ]; then
	ccache -M 0 -F 0
fi

# clear logfile if bigger than 2GiB
CCACHE_LOGSIZE=$((0x7FFFFFFF))

if [ -s "$CCACHE_LOGFILE" ] && [ $(stat -c %s "$CCACHE_LOGFILE") -gt $CCACHE_LOGSIZE ]; then
	> "$CCACHE_LOGFILE"
	ccache -z
fi

# print some stats on startup
ccache -s

log=$logs/$(date +%Y%m%d_%H%M%S)
install -d $log
mv $outdir/chromium-browser-*.*.*.*/src/REMOVED-*.txt $log
logfile=$log/rpmbuild.log
touch $logfile
rmdir $log

_smp_mflags=$(rpm -E %{?_smp_mflags})
time $dir/teeboth "$logfile" rpmbuild \
	${_smp_mflags:+--define "_smp_mflags ${_smp_mflags}"} \
	--define "_unpackaged_files_terminate_build 1" \
	--define '_enable_debug_packages 0' \
	--define "_topdir $dir" \
	--define "_specdir $dir" \
	--define "_sourcedir $dir" \
	--define "_builddir $outdir" \
	--define "_rpmdir $rpmdir" \
	--without debuginfo \
	--with verbose \
	--with ninja \
	"$@"
