#!/bin/sh

# Copyright (c) 2006-2009 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Always use our ffmpeg libs.
# Also symlinks for nss/nspr libs can be found from our dir.
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

# Google Chrome has a number of command line switches which change the behavior of Chrome
# This param allows you to set extra args for browser startup.
# See source for possible choices:
# http://git.chromium.org/gitweb/?p=chromium.git;f=chrome/common/chrome_switches.cc;hb=HEAD
# Also: http://peter.sh/experiments/chromium-command-line-switches/
CHROME_FLAGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/chromium/Chrome Flags"
if [ -f "$CHROME_FLAGS_FILE" ]; then
	# All lines starting with # are ignored
	CHROME_FLAGS=$(grep -v '^#' "$CHROME_FLAGS_FILE")
fi

exec @libdir@/chromium-browser --password-store=detect $CHROME_FLAGS "$@"
