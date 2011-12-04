#!/bin/sh
set -e
set -x

# import options
eval "$@"

# drop bundled libs, from gentoo
gyp_clean() {
	set +x
	local l lib=$1
	echo "Removing bundled library $lib ..."
	l=$(find "$lib" -mindepth 1 ! -iname '*.gyp*' -print -delete | wc -l)
	if [ $l -eq 0 ]; then
		echo >&2 "No files matched when removing bundled library $1"
		exit 1
	fi
}

rm -v third_party/expat/files/lib/expat.h

gyp_clean third_party/bzip2
gyp_clean third_party/icu
gyp_clean third_party/libevent
gyp_clean third_party/libjpeg
gyp_clean third_party/libpng
# third_party/libvpx/libvpx.h should be kept
#gyp_clean third_party/libvpx
gyp_clean third_party/libxml
gyp_clean third_party/libxslt
gyp_clean third_party/zlib
# third_party/yasm/source/patched-yasm/modules/arch/x86/gen_x86_insn.py', needed by `out/Release/obj/gen/third_party/yasm/x86insns.c'.  Stop.
#gyp_clean third_party/yasm

if [ $v8 = 1 ]; then
	# Remove bundled v8.
	gyp_clean v8

	# The implementation files include v8 headers with full path,
	# like #include "v8/include/v8.h". Make sure the system headers
	# will be used.
	rm -rf v8/include
	ln -s /usr/include v8/include
fi

if [ "$nacl" = 1 ]; then
	# NOTE: here is always x86_64
	rm -rf native_client/toolchain/linux_x86_newlib
	ln -s /usr/x86_64-nacl-newlib native_client/toolchain/linux_x86_newlib
fi
