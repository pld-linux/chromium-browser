#!/bin/sh

# Allow the user to override command-line flags, http://bugs.gentoo.org/357629
# This is based on Debian's chromium-browser package, and is intended
# to be consistent with Debian.
if [ -f /etc/chromium-browser/default ] ; then
	. /etc/chromium-browser/default
fi

# Always use our ffmpeg libs.
export LD_LIBRARY_PATH=@libdir@${LD_LIBRARY_PATH:+:"$LD_LIBRARY_PATH"}

# for to find xdg-settings
export PATH=@libdir@${PATH:+:"$PATH"}

# chromium needs /dev/shm being mounted
m=$(awk '$2 == "/dev/shm" && $3 == "tmpfs" {print}' /proc/mounts)
if [ -z "$m" ]; then
	cat >&2 <<-'EOF'
	Chromium needs /dev/shm being mounted for Shared Memory access.

	To do so, invoke (as root):
	mount -t tmpfs -o rw,nosuid,nodev,noexec none /dev/shm

	EOF
fi

# Set CHROME_VERSION_EXTRA visible in the About dialog and in about:version
export CHROME_VERSION_EXTRA="PLD Linux"

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

exec @libdir@/chromium-browser $CHROMIUM_FLAGS "$@"
