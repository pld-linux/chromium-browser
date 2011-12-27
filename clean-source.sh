#!/bin/sh
set -e
set -x

# import options
eval "$@"

# drop bundled libs, from gentoo
gyp_clean() {
	local l lib=$1
	echo "Removing bundled library $lib ..."
	l=$(find "$lib" -mindepth 1 ! -iname '*.gyp*' -print -delete | wc -l)
	if [ $l -eq 0 ]; then
		echo >&2 "No files matched when removing bundled library $1"
		exit 1
	fi
}

# https://code.google.com/p/chromium/wiki/LinuxPackaging
# initial list from src/tools/export_tarball/export_tarball.py
remove_nonessential_dirs() {
	local dir
	for dir in \
    chrome/common/extensions/docs \
    chrome/test/data \
    chrome/tools/test/reference_build \
    courgette/testdata \
    data \
    native_client/src/trusted/service_runtime/testdata \
    src/chrome/test/data \
    o3d/documentation \
    o3d/samples \
    o3d/tests \
    third_party/angle/samples/gles2_book \
    third_party/hunspell_dictionaries \
    third_party/hunspell/tests \
    third_party/lighttpd \
    third_party/sqlite/test \
    third_party/vc_80 \
    third_party/xdg-utils/tests \
    third_party/yasm/source/patched-yasm/modules/arch/x86/tests \
    third_party/yasm/source/patched-yasm/modules/dbgfmts/dwarf2/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/bin/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/coff/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/elf/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/macho/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/rdf/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/win32/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/win64/tests \
    third_party/yasm/source/patched-yasm/modules/objfmts/xdf/tests \
    third_party/WebKit/Source/JavaScriptCore/tests \
    third_party/WebKit/LayoutTests \
    v8/test \
    webkit/data/layout_tests \
    webkit/tools/test/reference_build \
	\
	tools/site_compare \
	tools/stats_viewer \
	tools/symsrc \
	tools/valgrind \
	; do
		rm -vfr "$dir"
	done
}

# Strip tarball from some big directories not needed on the linux platform
strip_dirs() {
	# prefix with _ those that we can't remove (just yet) because of the gclient
	# hooks (see build/all.gyp) or of some unneeded deps/includes

	local dir
	for dir in \
		chrome/test/data/safe_browsing/old \
		chrome/test/data/firefox2_nss_mac \
		chrome/third_party/wtl/ \
		gears \
		google_update \
		o3d \
		third_party/boost \
		third_party/bsdiff \
		third_party/bspatch \
		third_party/ffmpeg/binaries \
		third_party/fuzzymatch \
		third_party/gles_book_examples \
		third_party/hunspell/dictionaries \
		third_party/icu/mac \
		third_party/lcov \
		third_party/lighttpd \
		third_party/nspr \
		third_party/nss \
		third_party/ocmock \
		third_party/pthread \
		third_party/pyftpdlib \
		third_party/simplejson \
		third_party/scons \
		_third_party/tcmalloc \
		tools/symsrc \
		tools/site_compare \
		tools/stats_viewer \
		tools/valgrind \
		tools/wine_valgrind \
		v8/test/cctest \
		webkit/data/layout_tests \
	; do
		rm -vfr "$dir"
	done
}

# parts based on ubuntu debian/rules
# http://bazaar.launchpad.net/~chromium-team/chromium-browser/chromium-browser.head/view/head:/debian/rules

remove_bin_only() {
	find . -type f \( \
		-iname \*.exe -o \
		-iname \*.dll -o \
		-iname \*.pdb -o \
		-name \*.o -o \
		-name \*.a -o \
		-name \*.dylib \
	\) -exec rm -fv {} \;
}

# removes dir, if the bcond is not turned off
strip_system_dirs() {
	local dir lib bcond
	for dir in "$@"; do
		lib=${dir##*/}
		bcond=$(eval echo \$$lib)
		[ "$bcond" = 0 ] && continue

		# skip already removed dirs
		test -d $dir || continue

		# here we ignore errors, as some dirs contain README.chromium after removal
		find $dir -depth -mindepth 1 \! \( -name \*.gyp -o -name \*.gypi -o -name README.chromium -o -name \*.patch \) -print -delete || :
	done
}

# There are directories we want to strip, but that are unnecessarily required by the build-system
# So we drop everything but the gyp/gypi files and README.chromium (to see what that dir contained)
almost_strip_dirs() {
	local dir
	for dir in "$@"; do
		echo >&2 "almost strip dir: $dir"
		find $dir -depth -mindepth 1 \! \( -name \*.gyp -o -name \*.gypi -o -name README.chromium \) -print -delete || :
	done
}

remove_nonessential_dirs | tee -a REMOVED-nonessential_dirs.txt
remove_bin_only | tee -a REMOVED-bin_only.txt

strip_dirs | tee -a REMOVED-stripped.txt

almost_strip_dirs \
	courgette \
	third_party/gles2_book \
| tee -a REMOVED-stripped.txt

strip_system_dirs \
	third_party/bzip2 \
	third_party/icu \
	third_party/libevent \
	third_party/libjpeg \
	third_party/libpng \
	third_party/libxml \
	third_party/libxslt \
	third_party/zlib \
	third_party/libwebp \
	v8 \
| tee -a REMOVED-stripped.txt

# third_party/libvpx/libvpx.h should be kept
#gyp_clean third_party/libvpx
# third_party/yasm/source/patched-yasm/modules/arch/x86/gen_x86_insn.py', needed by `out/Release/obj/gen/third_party/yasm/x86insns.c'.  Stop.
#gyp_clean third_party/yasm

rm -vf third_party/expat/files/lib/expat.h

if [ "$v8" = 1 ]; then
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
