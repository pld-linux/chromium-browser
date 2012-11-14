#!/bin/sh
set -xe

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
# also removed non-linux files: find -name win -o -name mac
remove_nonessential_dirs() {
	local dir
	for dir in \
	chrome/common/extensions/docs \
	chrome/tools/test/reference_build \
	courgette/testdata \
	data \
	native_client/src/trusted/service_runtime/testdata \
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
	\
	_base/mac \
	_base/win \
	breakpad/src/client/mac \
	breakpad/src/common/mac \
	breakpad/src/tools/mac \
	build/mac \
	build/win \
	chrome/app/theme/default_100_percent/mac \
	chrome/app/theme/default_100_percent/win \
	chrome/app/theme/default_200_percent/mac \
	chrome/app/theme/default_200_percent/win \
	chrome/app/theme/touch_100_percent/win \
	chrome/app/theme/touch_140_percent/win \
	chrome/app/theme/touch_180_percent/win \
	chrome/browser/mac \
	chrome/common/mac \
	chrome/installer/mac \
	chrome/installer/mac/third_party/xz/config/mac \
	chrome/test/logging/win \
	chrome/tools/build/mac \
	chrome/tools/build/win \
	cloud_print/service/win \
	cloud_print/virtual_driver/win \
	_content/common/mac \
	content/shell/mac \
	media/audio/mac \
	media/audio/win \
	media/video/capture/mac \
	media/video/capture/win \
	native_client/build/mac \
	_native_client/src/include/win \
	native_client/src/shared/imc/win \
	native_client/src/shared/platform/win \
	native_client/src/trusted/debug_stub/win \
	native_client/src/trusted/desc/win \
	native_client/src/trusted/nonnacl_util/win \
	native_client/src/trusted/platform_qualify/win \
	_native_client/src/trusted/service_runtime/win \
	native_client_sdk/src/libraries/win \
	ppapi/native_client/src/trusted/plugin/win \
	remoting/host/installer/mac \
	remoting/host/mac \
	remoting/host/win \
	rlz/mac \
	rlz/win \
	_sandbox/win \
	sdch/mac \
	skia/config/win \
	third_party/WebKit/Source/Platform/chromium/public/mac \
	third_party/WebKit/Source/Platform/chromium/public/win \
	third_party/WebKit/Source/WTF/wtf/mac \
	third_party/WebKit/Source/WTF/wtf/threads/win \
	third_party/WebKit/Source/WTF/wtf/win \
	third_party/WebKit/Source/WebCore/WebCore.gyp/mac \
	third_party/WebKit/Source/WebCore/accessibility/mac \
	third_party/WebKit/Source/WebCore/accessibility/win \
	third_party/WebKit/Source/WebCore/editing/mac \
	third_party/WebKit/Source/WebCore/history/mac \
	third_party/WebKit/Source/WebCore/loader/mac \
	third_party/WebKit/Source/WebCore/loader/win \
	third_party/WebKit/Source/WebCore/page/mac \
	third_party/WebKit/Source/WebCore/page/scrolling/mac \
	third_party/WebKit/Source/WebCore/page/win \
	third_party/WebKit/Source/WebCore/platform/audio/mac \
	third_party/WebKit/Source/WebCore/platform/cf/win \
	third_party/WebKit/Source/WebCore/platform/graphics/ca/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/ca/win \
	third_party/WebKit/Source/WebCore/platform/graphics/gpu/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/surfaces/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/win \
	third_party/WebKit/Source/WebCore/platform/mac \
	third_party/WebKit/Source/WebCore/platform/network/mac \
	third_party/WebKit/Source/WebCore/platform/network/win \
	third_party/WebKit/Source/WebCore/platform/text/mac \
	third_party/WebKit/Source/WebCore/platform/text/win \
	third_party/WebKit/Source/WebCore/platform/win \
	third_party/WebKit/Source/WebCore/platform/wx/wxcode/mac \
	third_party/WebKit/Source/WebCore/platform/wx/wxcode/win \
	third_party/WebKit/Source/WebCore/plugins/mac \
	third_party/WebKit/Source/WebCore/plugins/win \
	_third_party/WebKit/Source/WebKit/chromium/public/mac \
	third_party/WebKit/Source/WebKit/chromium/public/platform/mac \
	third_party/WebKit/Source/WebKit/chromium/public/platform/win \
	third_party/WebKit/Source/WebKit/chromium/public/win \
	third_party/WebKit/Source/WebKit/chromium/src/mac \
	third_party/WebKit/Source/WebKit/chromium/src/win \
	third_party/WebKit/Source/WebKit/mac \
	third_party/WebKit/Source/WebKit/win \
	third_party/WebKit/Source/WebKit2/Platform/CoreIPC/mac \
	third_party/WebKit/Source/WebKit2/Platform/CoreIPC/win \
	third_party/WebKit/Source/WebKit2/Platform/mac \
	third_party/WebKit/Source/WebKit2/Platform/win \
	third_party/WebKit/Source/WebKit2/PluginProcess/mac \
	third_party/WebKit/Source/WebKit2/Shared/API/c/mac \
	third_party/WebKit/Source/WebKit2/Shared/API/c/win \
	third_party/WebKit/Source/WebKit2/Shared/Plugins/Netscape/mac \
	third_party/WebKit/Source/WebKit2/Shared/Plugins/Netscape/win \
	third_party/WebKit/Source/WebKit2/Shared/Plugins/mac \
	third_party/WebKit/Source/WebKit2/Shared/cg/win \
	third_party/WebKit/Source/WebKit2/Shared/mac \
	third_party/WebKit/Source/WebKit2/Shared/win \
	third_party/WebKit/Source/WebKit2/UIProcess/API/C/mac \
	third_party/WebKit/Source/WebKit2/UIProcess/API/C/win \
	third_party/WebKit/Source/WebKit2/UIProcess/API/mac \
	third_party/WebKit/Source/WebKit2/UIProcess/Launcher/mac \
	third_party/WebKit/Source/WebKit2/UIProcess/Launcher/win \
	third_party/WebKit/Source/WebKit2/UIProcess/Plugins/mac \
	third_party/WebKit/Source/WebKit2/UIProcess/Plugins/win \
	third_party/WebKit/Source/WebKit2/UIProcess/mac \
	third_party/WebKit/Source/WebKit2/UIProcess/win \
	third_party/WebKit/Source/WebKit2/WebProcess/Authentication/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/Cookies/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/Downloads/cf/win \
	third_party/WebKit/Source/WebKit2/WebProcess/Downloads/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/FullScreen/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/FullScreen/win \
	third_party/WebKit/Source/WebKit2/WebProcess/InjectedBundle/API/c/win \
	third_party/WebKit/Source/WebKit2/WebProcess/InjectedBundle/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/InjectedBundle/win \
	third_party/WebKit/Source/WebKit2/WebProcess/Plugins/Netscape/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/Plugins/Netscape/win \
	third_party/WebKit/Source/WebKit2/WebProcess/WebCoreSupport/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/WebCoreSupport/win \
	third_party/WebKit/Source/WebKit2/WebProcess/WebPage/ca/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/WebPage/ca/win \
	third_party/WebKit/Source/WebKit2/WebProcess/WebPage/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/WebPage/win \
	third_party/WebKit/Source/WebKit2/WebProcess/mac \
	third_party/WebKit/Source/WebKit2/WebProcess/win \
	third_party/WebKit/Source/WebKit2/mac \
	third_party/WebKit/Source/WebKit2/win \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/Tests/mac \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/Tests/win \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/mac \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/win \
	third_party/WebKit/Tools/DumpRenderTree/mac \
	third_party/WebKit/Tools/DumpRenderTree/win \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/TestWebKitAPI/mac \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/WebKit/win \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/WebKit2/mac \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/WebKit2/win \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/mac \
	third_party/WebKit/Tools/TestWebKitAPI/mac \
	third_party/WebKit/Tools/TestWebKitAPI/win \
	_third_party/cld/encodings/compact_lang_det/win \
	third_party/ffmpeg/chromium/binaries/Chromium/win \
	third_party/ffmpeg/chromium/config/Chrome/mac \
	third_party/ffmpeg/chromium/config/Chromium/mac \
	third_party/ffmpeg/chromium/include/win \
	third_party/leveldatabase/src/port/win \
	third_party/libjpeg_turbo/mac \
	third_party/libjpeg_turbo/win \
	third_party/libvpx/source/config/mac \
	third_party/libvpx/source/config/win \
	third_party/libxml/mac \
	third_party/skia/include/utils/mac \
	third_party/skia/include/utils/win \
	third_party/skia/src/gpu/gl/mac \
	third_party/skia/src/gpu/gl/win \
	third_party/skia/src/utils/mac \
	third_party/skia/src/utils/win \
	third_party/skia/src/views/mac \
	third_party/skia/src/views/win \
	third_party/snappy/mac \
	third_party/webrtc/modules/audio_device/main/source/mac \
	third_party/webrtc/modules/audio_device/main/source/win \
	third_party/webrtc/modules/video_render/main/source/mac \
	third_party/webrtc/test/testsupport/mac \
	third_party/yasm/source/config/mac \
	third_party/yasm/source/config/win \
	tools/mac \
	tools/win \
	_ui/base/win \
	ui/gfx/mac \
	ui/views/win \
	webkit/tools/test_shell/mac \
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
		find $dir -depth -mindepth 1 \! \( -name '*.gyp' -o -name '*.gypi' -o -name README.chromium -o -name '*.patch' -o -path $dir/$lib.h \) -print -delete || :
	done
}

# There are directories we want to strip, but that are unnecessarily required by the build-system
# So we drop everything but the gyp/gypi files and README.chromium (to see what that dir contained)
almost_strip_dirs() {
	local dir
	for dir in "$@"; do
		find $dir -depth -mindepth 1 \! \( -name '*.gyp' -o -name '*.gypi' -o -name README.chromium \) -print -delete || :
	done
}

remove_nonessential_dirs | tee -a REMOVED-nonessential_dirs.txt
remove_bin_only | tee -a REMOVED-bin_only.txt

strip_dirs | tee -a REMOVED-stripped.txt

almost_strip_dirs \
	courgette \
	chrome/test/data \
	third_party/gles2_book \
| tee -a REMOVED-stripped.txt

strip_system_dirs \
	native_client/src/third_party_mod/jsoncpp \
	third_party/bzip2 \
	third_party/flac \
	third_party/icu \
	third_party/jsoncpp \
	third_party/libevent \
	third_party/libjpeg \
	third_party/libpng \
	_third_party/libvpx \
	third_party/libwebp \
	_third_party/libxml \
	third_party/libxslt \
	third_party/speex \
	_third_party/zlib \
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
