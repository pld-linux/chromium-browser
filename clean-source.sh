#!/bin/sh

# import options
eval "$@"

# drop bundled libs, from gentoo
remove_bundled_lib() {
	set +x
	echo "Removing bundled library $1 ..."
	local out
	out=$(find $1 -mindepth 1 ! -iname '*.gyp' -print -delete)
	if [ -z "$out" ]; then
		echo >&2 "No files matched when removing bundled library $1"
		exit 1
	fi
}

rm -v third_party/expat/files/lib/expat.h
remove_bundled_lib "third_party/bzip2"
remove_bundled_lib "third_party/icu"
remove_bundled_lib "third_party/libevent"
remove_bundled_lib "third_party/libjpeg"
remove_bundled_lib "third_party/libpng"
# third_party/libvpx/libvpx.h should be kept
#remove_bundled_lib "third_party/libvpx"
remove_bundled_lib "third_party/libxml"
remove_bundled_lib "third_party/libxslt"
remove_bundled_lib "third_party/zlib"
# third_party/yasm/source/patched-yasm/modules/arch/x86/gen_x86_insn.py', needed by `out/Release/obj/gen/third_party/yasm/x86insns.c'.  Stop.
#remove_bundled_lib "third_party/yasm"

if [ $v8 = 1 ]; then
	# Remove bundled v8.
	find v8 -type f \! -iname '*.gyp*' -delete

	# The implementation files include v8 headers with full path,
	# like #include "v8/include/v8.h". Make sure the system headers
	# will be used.
	rmdir v8/include
	ln -s /usr/include v8/include
fi

if [ "$nacl" = 1 ]; then
	# NOTE: here is always x86_64
	rm -rf native_client/toolchain/linux_x86_newlib
	ln -s /usr/x86_64-nacl-newlib native_client/toolchain/linux_x86_newlib
fi
