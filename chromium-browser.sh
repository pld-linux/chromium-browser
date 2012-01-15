#!/bin/sh

# Copyright (c) 2006-2009 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

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
	CHROME_FLAGS=$(grep -v '^#' "$CHROME_FLAGS_FILE")
fi

# Google guys cannot properly handle comma, so download speed/est is shown
# as not a number (NaN). Workaround that with LC_NUMERIC=C
export LC_NUMERIC=C

exec @libdir@/chromium-browser $CHROME_FLAGS "$@"
