#!/bin/sh
set -e
set -x

# import options
# remove everything unless it's remove has been disabled with "0"
# "v8=0" means "do not remove v8"
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
# some scanned with find -name tests -o -name test -o -name test_data
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
	\
	breakpad/src/client/mac/tests \
	breakpad/src/client/windows/tests \
	breakpad/src/common/linux/tests \
	breakpad/src/common/tests \
	chrome/browser/resources/tracing/tests \
	chrome/browser/ui/tests \
	content/test/data/layout_tests/LayoutTests/http/tests \
	content/test/data/layout_tests/LayoutTests/http/tests/websocket/tests \
	content/test/data/layout_tests/LayoutTests/platform/chromium-win/http/tests \
	gpu/command_buffer/tests \
	native_client/tests \
	native_client/tools/tests \
	native_client_sdk/src/build_tools/tests \
	ppapi/native_client/tests \
	ppapi/tests \
	sandbox/tests \
	seccompsandbox/tests \
	third_party/WebKit/Source/JavaScriptCore/API/tests \
	third_party/WebKit/Source/JavaScriptCore/qt/tests \
	third_party/WebKit/Source/WebKit/chromium/tests \
	third_party/WebKit/Source/WebKit/gtk/tests \
	third_party/WebKit/Source/WebKit/qt/tests \
	third_party/WebKit/Source/WebKit2/UIProcess/API/gtk/tests \
	third_party/WebKit/Source/WebKit2/UIProcess/API/qt/tests \
	third_party/angle/tests \
	third_party/ffmpeg/tests \
	third_party/harfbuzz/tests \
	third_party/hyphen/tests \
	third_party/mesa/MesaLib/src/gallium/tests \
	third_party/mesa/MesaLib/src/gallium/tests/python/tests \
	third_party/tcmalloc/chromium/src/tests \
	third_party/tcmalloc/vendor/src/tests \
	third_party/yasm/source/patched-yasm/libyasm/tests \
	third_party/yasm/source/patched-yasm/modules/arch/lc3b/tests \
	third_party/yasm/source/patched-yasm/modules/dbgfmts/stabs/tests \
	third_party/yasm/source/patched-yasm/modules/parsers/gas/tests \
	third_party/yasm/source/patched-yasm/modules/parsers/nasm/tests \
	third_party/yasm/source/patched-yasm/modules/parsers/tasm/tests \
	third_party/yasm/source/patched-yasm/modules/preprocs/nasm/tests \
	third_party/yasm/source/patched-yasm/modules/preprocs/raw/tests \
	third_party/yasm/source/patched-yasm/tools/python-yasm/tests \
	tools/clang/plugins/tests \
	tools/page_cycler/webpagereplay/tests \
	tools/perf_expectations/tests \
	\
	v8/test \
	webkit/data/layout_tests \
	webkit/tools/test/reference_build \
	\
	tools/site_compare \
	tools/stats_viewer \
	tools/symsrc \
	tools/valgrind \
	tools/gyp/test \
	\
	ash/test \
	base/android/javatests/src/org/chromium/base/test \
	base/test \
	chrome/browser/chromeos/bluetooth/test \
	chrome/browser/component_updater/test \
	chrome/browser/printing/cloud_print/test \
	chrome/browser/resources/gaia_auth/test \
	chrome/browser/sync/test \
	chrome/installer/test \
	chrome/test/webdriver/test \
	chrome/tools/test \
	chrome_frame/test \
	chrome_frame/tools/test \
	content/browser/worker_host/test \
	content/public/test \
	content/test \
	media/test \
	media/tools/layout_tests/test_data \
	native_client_sdk/src/libraries/c_salt/test \
	net/test \
	printing/test \
	rlz/test \
	sandbox/linux/seccomp-legacy/tests \
	sandbox/linux/tests \
	sandbox/win/tests \
	sync/internal_api/public/test \
	sync/internal_api/test \
	sync/test \
	testing/gmock/scripts/test \
	testing/gmock/test \
	testing/gtest/scripts/test \
	testing/gtest/test \
	third_party/WebKit/Source/ThirdParty/gtest/scripts/test \
	third_party/WebKit/Source/ThirdParty/gtest/test \
	third_party/WebKit/Source/ThirdParty/gyp/test \
	third_party/WebKit/Source/ThirdParty/qunit/test \
	third_party/WebKit/Source/WebCore/bindings/scripts/test \
	third_party/WebKit/Source/WebKit/efl/tests \
	third_party/WebKit/Source/WebKit2/UIProcess/API/efl/tests \
	third_party/WebKit/Tools/Scripts/webkitpy/test \
	third_party/cacheinvalidation/files/src/google/cacheinvalidation/test \
	third_party/libexif/sources/test \
	third_party/libjingle/source/talk/app/webrtc/test \
	third_party/libphonenumber/src/resources/test \
	third_party/libphonenumber/src/test \
	third_party/libsrtp/srtp/crypto/test \
	third_party/libsrtp/srtp/test \
	third_party/openssl/openssl/crypto/des/t/test \
	third_party/openssl/openssl/test \
	third_party/ots/test \
	third_party/sfntly/cpp/src/test \
	third_party/sqlite/src/test \
	third_party/talloc/libreplace/test \
	third_party/tlslite/test \
	third_party/trace-viewer/test_data \
	third_party/v8-i18n/tests \
	third_party/webdriver/pylib/test \
	third_party/webdriver/test_data \
	ui/app_list/test \
	ui/aura/test \
	ui/base/test \
	ui/compositor/test \
	ui/gfx/test \
	ui/test \
	ui/views/test \
	webkit/plugins/npapi/test \
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
		[ "${bcond:-1}" = 0 ] && continue

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
	_third_party/libxml \
	third_party/libxslt \
	_third_party/zlib \
	third_party/libwebp \
	_third_party/libvpx \
	v8 \
| tee -a REMOVED-stripped.txt

# vpx can't be cleaned:
#make: *** No rule to make target `out/Release/obj.target/libvpx_asm_offsets/third_party/libvpx/source/libvpx/vp8/common/asm_com_offsets.o',
#needed by `out/Release/obj.target/third_party/libvpx/libvpx_asm_offsets.a'.  Stop.

# third_party/yasm/source/patched-yasm/modules/arch/x86/gen_x86_insn.py', needed by `out/Release/obj/gen/third_party/yasm/x86insns.c'. Stop.
#gyp_clean third_party/yasm

rm -vf third_party/expat/files/lib/expat.h

if [ "${v8:-1}" != "0" ]; then
	# The implementation files include v8 headers with full path,
	# like #include "v8/include/v8.h". Make sure the system headers
	# will be used.
	rm -rf v8/include
	ln -s /usr/include v8/include
fi

if [ "${nacl:-1}" != "0" ]; then
	# NOTE: here is always x86_64
	rm -rf native_client/toolchain/linux_x86_newlib
fi
