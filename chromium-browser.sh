#!/bin/sh
APPNAME=chromium-browser
LIBDIR=@libdir@
GDB=/usr/bin/gdb

# Allow the user to override command-line flags, http://bugs.gentoo.org/357629
# This is based on Debian's chromium-browser package, and is intended
# to be consistent with Debian.
if [ -f /etc/$APPNAME/default ] ; then
	. /etc/$APPNAME/default
fi

die() {
	echo >&2 "$*"
	exit 1
}

usage() {
	echo "$APPNAME [-h|--help] [-g|--debug] [--temp-profile] [options] [URL]"
	echo
	echo "        -g or --debug           Start within $GDB"
	echo "        -h or --help            This help screen"
	echo "        --temp-profile          Start with a new and temporary profile"
	echo
	echo "Other supported options are:"
	MANWIDTH=80 man $APPNAME | sed -e '1,/OPTIONS/d; /ENVIRONMENT/,$d'
	echo "See 'man $APPNAME' for more details"
}

export LD_LIBRARY_PATH=$LIBDIR${LD_LIBRARY_PATH:+:"$LD_LIBRARY_PATH"}

# for to find xdg-settings
export PATH=$LIBDIR${PATH:+:"$PATH"}

# chromium needs /dev/shm being mounted
m=$(awk '$2 == "/dev/shm" && $3 == "tmpfs" {print}' /proc/mounts)
if [ -z "$m" ]; then
	cat >&2 <<-'EOF'
	Chromium needs /dev/shm being mounted for Shared Memory access.

	To do so, invoke (as root):
	mount -t tmpfs -o rw,nosuid,nodev,noexec none /dev/shm

	EOF
fi

# lsb_release is slow so try to source the static file /etc/lsb-release
# instead, and fallback to lsb_release if we didn't get the information we need
if [ -e /etc/lsb-release ] ; then
	. /etc/lsb-release
fi
DIST=${DISTRIB_ID:-$(lsb_release -si)}
RELEASE=${DISTRIB_CODENAME:-$(lsb_release -sc)}

# Set CHROME_VERSION_EXTRA visible in the About dialog and in about:version
export CHROME_VERSION_EXTRA="$DIST Linux $RELEASE"

# Let the wrapped binary know that it has been run through the wrapper
export CHROME_WRAPPER="$(readlink -f "$0")"

# Google Chrome has a number of command line switches which change the behavior of Chrome
# This param allows you to set extra args for browser startup.
# See: http://peter.sh/experiments/chromium-command-line-switches/
CHROME_FLAGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/chromium/Chrome Flags"
if [ -f "$CHROME_FLAGS_FILE" ]; then
	# All lines starting with # are ignored
	CHROMIUM_USER_FLAGS=$(grep -v '^#' "$CHROME_FLAGS_FILE")
fi

# Prefer user defined CHROMIUM_USER_FLAGS (from env) over system
# default CHROMIUM_FLAGS (from /etc/chromium-browser/default).
CHROMIUM_FLAGS=${CHROMIUM_USER_FLAGS:-"$CHROMIUM_FLAGS"}

# Google guys cannot properly handle comma, so download speed/est is shown
# as not a number (NaN). Workaround that with LC_NUMERIC=C
export LC_NUMERIC=C

# load PepperFlash if present
PEPFLASH=$(readlink -f $LIBDIR/../browser-plugins/PepperFlash)
if [ -f $PEPFLASH/manifest.ver ]; then
	. $PEPFLASH/manifest.ver
	CHROMIUM_FLAGS="$CHROMIUM_FLAGS --ppapi-flash-path=$PEPFLASH/libpepflashplayer.so --ppapi-flash-version=$version"
fi

want_debug=0
want_temp_profile=0
while [ $# -gt 0 ]; do
	case "$1" in
	-h | --help | -help)
		usage
		exit 0 ;;
	-g | --debug)
		want_debug=1
		shift ;;
	--temp-profile)
		want_temp_profile=1
		shift ;;
	-- ) # Stop option prcessing
		shift
		break ;;
	*)
		break ;;
	esac
done

if [ $want_temp_profile -eq 1 ]; then
	TEMP_PROFILE=$(mktemp -d) || exit 1
	CHROMIUM_FLAGS="$CHROMIUM_FLAGS --user-data-dir=$TEMP_PROFILE"
fi

if [ $want_debug -eq 1 ]; then
	if [ ! -x $GDB ] ; then
		die "Sorry, can't find usable $GDB. Please install it."
	fi

	tmpfile=$(mktemp /tmp/chromiumargs.XXXXXX) || die "Cannot create temporary file"
	trap " [ -f \"$tmpfile\" ] && /bin/rm -f -- \"$tmpfile\"" 0 1 2 3 13 15
	echo "set args $CHROMIUM_FLAGS ${1+"$@"}" > $tmpfile
	echo "# Env:"
	echo "#     LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
	echo "#                PATH=$PATH"
	echo "#            GTK_PATH=$GTK_PATH"
	echo "# CHROMIUM_USER_FLAGS=$CHROMIUM_USER_FLAGS"
	echo "#      CHROMIUM_FLAGS=$CHROMIUM_FLAGS"
	echo "$GDB $LIBDIR/$APPNAME -x $tmpfile"
	$GDB "$LIBDIR/$APPNAME" -x $tmpfile
	rc=$?
	if [ $want_temp_profile -eq 1 ]; then
		rm -rf $TEMP_PROFILE
	fi
	exit $rc
else
	if [ $want_temp_profile -eq 0 ]; then
		exec $LIBDIR/$APPNAME $CHROMIUM_FLAGS "$@"
	else
		# we can't exec here as we need to clean-up the temporary profile
		$LIBDIR/$APPNAME $CHROMIUM_FLAGS "$@"
		rm -rf $TEMP_PROFILE
	fi
fi
