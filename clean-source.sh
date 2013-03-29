#!/bin/sh
set -xe

export LC_ALL=C

# import options
# remove everything unless it's remove has been disabled with "0"
# "v8=0" means "do not remove v8"
eval "$@"

# Strip tarball from some big directories not needed on the linux platform
# https://code.google.com/p/chromium/wiki/LinuxPackaging
# initial list from src/tools/export_tarball/export_tarball.py
# also removed non-linux files: find -name win -o -name mac -o name android -o name windows
# find -type d -name 'android' -o -name 'chromeos' -o -name 'cros'
# find -type d -name *doc*
# find -type d -name *example*
# find -type d -name java
# find -type d -name tools
# find -type d -name samples
# suffix with _ those that we can't remove (just yet) because of the gclient
# hooks (see build/all.gyp) or of some unneeded deps/includes
remove_nonessential_dirs() {
	find -type f '(' \
		-name 'Android.mk' -o \
		-name '*.vcproj' -o \
		-name '*.sln' -o \
		-name '*.mm' -o \
		-name '*.m' \
	')' | xargs rm -vf

	find -regextype posix-extended \
		-regex '.*_(win|cros|mac)_.*.xtb' \
	-print -delete

	local dir
	for dir in \
	v8/benchmarks \
	v8/src/arm \
	v8/src/d8* \
	android_webview \
	ash/resources/default_100_percent/cros_ \
	ash/resources/default_200_percent/cros_ \
	ash/shell/cocoa \
	ash/system/chromeos \
	base/android \
	base/chromeos \
	base/ios \
	breakpad/src/client/mac \
	breakpad/src/common/android \
	breakpad/src/common/mac \
	breakpad/src/tools/mac \
	build/mac \
	build/win \
	chrome/android \
	chrome/app/android \
	chrome/app/resources/terms/chromeos \
	chrome/app/theme/default_100_percent/cros_ \
	chrome/app/theme/default_100_percent/mac \
	chrome/app/theme/default_100_percent/win \
	chrome/app/theme/default_200_percent/cros_ \
	chrome/app/theme/default_200_percent/mac \
	chrome/app/theme/default_200_percent/win \
	chrome/app/theme/touch_100_percent/win \
	chrome/app/theme/touch_140_percent/win \
	chrome/app/theme/touch_180_percent/win \
	chrome/browser/android \
	chrome/browser/chromeos/cros \
	chrome/browser/extensions/docs \
	chrome/browser/history/android \
	chrome/browser/mac \
	chrome/browser/resources/about_welcome_android \
	chrome/browser/resources/chromeos_ \
	chrome/browser/resources/ntp_android \
	chrome/browser/resources/options/chromeos_ \
	chrome/browser/resources/shared/css/chromeos \
	chrome/browser/resources/shared/js/chromeos_ \
	chrome/browser/ui/android \
	chrome/browser/ui/cocoa \
	chrome/browser/ui/webui/chromeos \
	chrome/browser/ui/webui/ntp/android \
	chrome/browser/ui/webui/options/chromeos \
	chrome/common/extensions/docs \
	chrome/common/mac \
	chrome/installer/mac \
	chrome/installer/mac/third_party/xz/config/mac \
	chrome/installer/tools \
	chrome/third_party/jstemplate/tutorial_examples \
	third_party/jstemplate/tutorial_examples \
	chrome/third_party/mock4js/examples \
	chrome/third_party/wtl/ \
	chrome/tools/build/chromeos \
	chrome/tools/build/mac \
	chrome/tools/build/win \
	chrome_frame \
	cloud_print/service/win \
	cloud_print/virtual_driver/win \
	content/app/android \
	content/browser/android \
	content/common/android \
	content/components/navigation_interception/java \
	content/components/web_contents_delegate_android/java \
	content/public/android \
	content/public/browser/android \
	content/renderer/android \
	content/shell/android \
	content/shell/mac \
	data \
	gears \
	google_update \
	gpu/command_buffer/docs \
	gpu/demos \
	media/audio/android \
	media/audio/ios \
	media/audio/mac \
	media/audio/win \
	media/base/android \
	media/tools \
	media/video/capture/mac \
	media/video/capture/win \
	media/webm/chromeos \
	mesa/MesaLib/src/mesa/drivers/windows \
	native_client/build/mac \
	native_client/documentation \
	native_client/src/shared/imc/win \
	native_client/src/shared/platform/win \
	native_client/src/tools \
	native_client/src/trusted/debug_stub/win \
	native_client/src/trusted/desc/win \
	native_client/src/trusted/nonnacl_util/win \
	native_client/src/trusted/platform_qualify/win \
	native_client/tools \
	native_client/tools/trusted_cross_toolchains \
	native_client_sdk \
	native_client_sdk/src/libraries/win \
	net/android \
	net/tools \
	net/tools/testserver \
	npapi/npspy/windows \
	o3d \
	o3d/documentation \
	o3d/samples \
	ppapi/c/documentation \
	ppapi/cpp/documentation \
	ppapi/native_client/src/tools \
	ppapi/native_client/src/trusted/plugin/win \
	ppapi/native_client/tools \
	remoting/host/installer/mac \
	remoting/host/installer/win \
	remoting/host/mac \
	remoting/host/setup/win \
	remoting/host/win \
	rlz/examples \
	rlz/mac \
	rlz/win \
	sandbox/win/tools \
	sdch/ios \
	sdch/mac \
	skia/config/win \
	sync/tools \
	tcmalloc/chromium/src/windows \
	tcmalloc/vendor/src/windows \
	third_party/WebKit/Source/JavaScriptCore/docs \
	third_party/WebKit/Source/JavaScriptCore/tools \
	third_party/WebKit/Source/Platform/chromium/public/android \
	third_party/WebKit/Source/Platform/chromium/public/mac \
	third_party/WebKit/Source/Platform/chromium/public/win \
	third_party/WebKit/Source/ThirdParty/gtest/samples \
	third_party/WebKit/Source/ThirdParty/gyp/samples \
	third_party/WebKit/Source/ThirdParty/gyp/samples/samples \
	third_party/WebKit/Source/ThirdParty/gyp/tools \
	third_party/WebKit/Source/WTF/wtf/mac \
	third_party/WebKit/Source/WTF/wtf/qt \
	third_party/WebKit/Source/WTF/wtf/threads/win \
	third_party/WebKit/Source/WTF/wtf/win \
	third_party/WebKit/Source/WebCore/WebCore.gyp/mac \
	third_party/WebKit/Source/WebCore/accessibility/mac \
	third_party/WebKit/Source/WebCore/accessibility/qt \
	third_party/WebKit/Source/WebCore/accessibility/win \
	third_party/WebKit/Source/WebCore/bridge/qt \
	third_party/WebKit/Source/WebCore/editing/android \
	third_party/WebKit/Source/WebCore/editing/mac \
	third_party/WebKit/Source/WebCore/editing/qt \
	third_party/WebKit/Source/WebCore/history/android \
	third_party/WebKit/Source/WebCore/history/mac \
	third_party/WebKit/Source/WebCore/history/qt \
	third_party/WebKit/Source/WebCore/loader/mac \
	third_party/WebKit/Source/WebCore/loader/win \
	third_party/WebKit/Source/WebCore/page/android \
	third_party/WebKit/Source/WebCore/page/mac \
	third_party/WebKit/Source/WebCore/page/qt \
	third_party/WebKit/Source/WebCore/page/scrolling/mac \
	third_party/WebKit/Source/WebCore/page/win \
	third_party/WebKit/Source/WebCore/platform/android \
	third_party/WebKit/Source/WebCore/platform/audio/mac \
	third_party/WebKit/Source/WebCore/platform/audio/qt \
	third_party/WebKit/Source/WebCore/platform/cf/win \
	third_party/WebKit/Source/WebCore/platform/cocoa \
	third_party/WebKit/Source/WebCore/platform/graphics/ca/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/ca/win \
	third_party/WebKit/Source/WebCore/platform/graphics/cocoa \
	third_party/WebKit/Source/WebCore/platform/graphics/gpu/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/gpu/qt \
	third_party/WebKit/Source/WebCore/platform/graphics/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/qt \
	third_party/WebKit/Source/WebCore/platform/graphics/surfaces/mac \
	third_party/WebKit/Source/WebCore/platform/graphics/surfaces/qt \
	third_party/WebKit/Source/WebCore/platform/graphics/surfaces/win \
	third_party/WebKit/Source/WebCore/platform/graphics/win \
	third_party/WebKit/Source/WebCore/platform/ios \
	third_party/WebKit/Source/WebCore/platform/mac \
	third_party/WebKit/Source/WebCore/platform/network/android \
	third_party/WebKit/Source/WebCore/platform/network/mac \
	third_party/WebKit/Source/WebCore/platform/network/qt \
	third_party/WebKit/Source/WebCore/platform/network/win \
	third_party/WebKit/Source/WebCore/platform/qt \
	third_party/WebKit/Source/WebCore/platform/text/android \
	third_party/WebKit/Source/WebCore/platform/text/mac \
	third_party/WebKit/Source/WebCore/platform/text/qt \
	third_party/WebKit/Source/WebCore/platform/text/win \
	third_party/WebKit/Source/WebCore/platform/win \
	third_party/WebKit/Source/WebCore/platform/wx/wxcode/mac \
	third_party/WebKit/Source/WebCore/platform/wx/wxcode/win \
	third_party/WebKit/Source/WebCore/plugins/mac \
	third_party/WebKit/Source/WebCore/plugins/qt \
	third_party/WebKit/Source/WebCore/plugins/win \
	third_party/WebKit/Source/WebKit/chromium/public/android \
	third_party/WebKit/Source/WebKit/chromium/public/platform/android \
	third_party/WebKit/Source/WebKit/chromium/public/platform/mac \
	third_party/WebKit/Source/WebKit/chromium/public/platform/win \
	third_party/WebKit/Source/WebKit/chromium/public/win \
	third_party/WebKit/Source/WebKit/chromium/src/android \
	third_party/WebKit/Source/WebKit/chromium/src/mac \
	third_party/WebKit/Source/WebKit/chromium/src/win \
	third_party/WebKit/Source/WebKit/gtk/docs \
	third_party/WebKit/Source/WebKit/mac \
	third_party/WebKit/Source/WebKit/qt \
	third_party/WebKit/Source/WebKit/qt/docs \
	third_party/WebKit/Source/WebKit/qt/examples \
	third_party/WebKit/Source/WebKit/win \
	third_party/WebKit/Source/WebKit/wx/bindings/python/samples \
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
	third_party/WebKit/Tools/DumpRenderTree/mac \
	third_party/WebKit/Tools/DumpRenderTree/qt \
	third_party/WebKit/Tools/DumpRenderTree/win \
	third_party/angle/extensions \
	third_party/angle/samples \
	third_party/angle/samples/gles2_book \
	third_party/boost \
	third_party/bsdiff \
	third_party/bspatch \
	third_party/cacheinvalidation/src/example-app-build \
	third_party/cacheinvalidation/src/java \
	third_party/cacheinvalidation/src/java/com/google/ipc/invalidation/external/client/android \
	third_party/cacheinvalidation/src/java/com/google/ipc/invalidation/ticl/android \
	third_party/ffmpeg/binaries \
	third_party/ffmpeg/chromium/binaries/Chromium/win \
	third_party/ffmpeg/chromium/config/Chrome/mac \
	third_party/ffmpeg/chromium/config/Chrome/win \
	third_party/ffmpeg/chromium/config/Chromium/mac \
	third_party/ffmpeg/chromium/config/Chromium/win \
	third_party/ffmpeg/chromium/include/win \
	third_party/ffmpeg/doc \
	third_party/ffmpeg/tools \
	third_party/fuzzymatch \
	third_party/gles2_book \
	third_party/gles_book_examples \
	third_party/gold \
	third_party/hunspell/dictionaries \
	third_party/hunspell_dictionaries \
	third_party/hyphen/doc \
	third_party/icu/android \
	third_party/icu/mac \
	third_party/lcov \
	third_party/leveldatabase/src/doc \
	third_party/leveldatabase/src/port/win \
	third_party/libjingle/source/talk/examples \
	third_party/libjpeg_turbo/mac \
	third_party/libjpeg_turbo/win \
	third_party/libva/va/android \
	third_party/libvpx/source/config/mac \
	third_party/libvpx/source/config/win \
	third_party/libxml/mac \
	third_party/lighttpd \
	third_party/mesa/MesaLib/docs \
	third_party/mesa/MesaLib/src/gallium/docs \
	third_party/npapi/npspy/extern/java \
	third_party/nspr \
	third_party/nss \
	third_party/ocmock \
	third_party/openssl/config/android \
	third_party/ots/tools \
	third_party/pthread \
	third_party/pyftpdlib \
	third_party/re2/doc \
	third_party/scons \
	third_party/sfntly/cpp/src/sfntly/tools \
	third_party/simplejson \
	third_party/skia/include/utils/android \
	third_party/skia/include/utils/ios \
	third_party/skia/include/utils/mac \
	third_party/skia/include/utils/win \
	third_party/skia/include/views/android \
	third_party/skia/src/gpu/gl/android \
	third_party/skia/src/gpu/gl/mac \
	third_party/skia/src/gpu/gl/win \
	third_party/skia/src/utils/ios \
	third_party/skia/src/utils/mac \
	third_party/skia/src/utils/win \
	third_party/skia/src/views/ios \
	third_party/skia/src/views/mac \
	third_party/skia/src/views/win \
	third_party/snappy/mac \
	third_party/sqlite/src/doc \
	third_party/tcmalloc/vendor/doc \
	third_party/trace-viewer/examples \
	third_party/trace-viewer/third_party/pywebsocket/src/example \
	third_party/vc_80 \
	third_party/webdriver/pylib/docs \
	third_party/webrtc/modules/audio_device/android \
	third_party/webrtc/modules/audio_device/ios \
	third_party/webrtc/modules/audio_device/main/source/mac \
	third_party/webrtc/modules/audio_device/main/source/win \
	third_party/webrtc/modules/audio_device/win \
	third_party/webrtc/modules/video_capture/android/java \
	third_party/webrtc/modules/video_capture/main/source/android \
	third_party/webrtc/modules/video_render/android/java \
	third_party/webrtc/modules/video_render/main/source/android \
	third_party/webrtc/modules/video_render/main/source/mac \
	third_party/webrtc/system_wrappers/source/android \
	third_party/yasm/source/config/android \
	third_party/yasm/source/config/mac \
	third_party/yasm/source/config/win \
	tools/android \
	tools/gyp/samples \
	tools/gyp/samples/samples \
	tools/gyp/tools \
	tools/mac \
	tools/site_compare \
	tools/stats_viewer \
	tools/symsrc \
	tools/valgrind \
	tools/win \
	tools/wine_valgrind \
	ui/android \
	ui/base/cocoa \
	ui/base/ime/win \
	ui/gfx/android \
	ui/gfx/mac \
	ui/resources/default_100_percent/cros_ \
	ui/resources/default_200_percent/cros_ \
	ui/views/examples \
	ui/views/win \
	v8/samples \
	webkit/chromeos \
	webkit/media/android \
	webrtc/modules/video_capture/windows \
	webrtc/modules/video_render/windows \
	win8 \
	; do
		rm -vfr "$dir"
	done

	find $(ls -d \
		base/mac \
		base/win \
		build/android \
		chrome/browser/chromeos \
		chrome/browser/component/web_contents_delegate_android \
		chrome/tools \
		chromeos \
		content/browser/renderer_host/java \
		content/common/mac \
		content/renderer/java \
		gpu/tools \
		native_client/src/include/win \
		native_client/src/trusted/service_runtime/win \
		remoting/tools \
		sandbox/win \
		third_party/WebKit/Source/WebKit/chromium/public/mac \
		third_party/WebKit/Tools \
		third_party/cld/encodings/compact_lang_det/win \
		third_party/cros_system_api \
		third_party/mozc/chrome/chromeos \
		third_party/sfntly/cpp/src/sample \
		third_party/tcmalloc \
		third_party/v8-i18n/tools \
		third_party/webrtc/modules/video_coding/codecs/tools \
		third_party/webrtc/tools \
		ui/base/win \
		v8/tools \
		webkit/tools \
	) '!' -type d '(' \
		'!' -name '*.grd' \
		'!' -name '*.gyp*' \
		'!' -path 'base/mac/bundle_locations.h' \
		'!' -path 'base/mac/crash_logging.h' \
		'!' -path 'base/win/windows_version.h' \
		'!' -path 'build/android/cpufeatures.gypi' \
		'!' -path 'chrome/browser/chromeos/contacts/contact.proto' \
		'!' -path 'chrome/browser/chromeos/extensions/echo_private_api.h' \
		'!' -path 'chrome/browser/chromeos/extensions/file_browser_handler_api.h' \
		'!' -path 'chrome/browser/chromeos/extensions/info_private_api.h' \
		'!' -path 'chrome/browser/chromeos/extensions/media_player_api.h' \
		'!' -path 'chrome/browser/chromeos/extensions/networking_private_api.h' \
		'!' -path 'chrome/browser/chromeos/extensions/wallpaper_private_api.h' \
		'!' -path 'chrome/browser/chromeos/settings/cros_settings.h' \
		'!' -path 'chrome/browser/chromeos/settings/cros_settings_names.h' \
		'!' -path 'chrome/browser/chromeos/settings/cros_settings_provider.h' \
		'!' -path 'chrome/browser/chromeos/settings/device_settings_service.h' \
		'!' -path 'chrome/tools/build/generate_policy_source.py' \
		'!' -path 'chrome/tools/build/linux/sed.sh' \
		'!' -path 'chrome/tools/build/make_version_cc.py' \
		'!' -path 'chrome/tools/build/repack_locales.py' \
		'!' -path 'chrome/tools/build/version.py' \
		'!' -path 'chromeos/chromeos_export.h' \
		'!' -path 'chromeos/chromeos_switches.h' \
		'!' -path 'chromeos/dbus/dbus_client_implementation_type.h' \
		'!' -path 'chromeos/dbus/session_manager_client.h' \
		'!' -path 'chromeos/network/onc/onc_constants.h' \
		'!' -path 'content/browser/renderer_host/java/java_bridge_dispatcher_host_manager.h' \
		'!' -path 'content/common/mac/attributed_string_coder.h' \
		'!' -path 'content/common/mac/font_descriptor.h' \
		'!' -path 'content/renderer/java/java_bridge_dispatcher.h' \
		'!' -path 'native_client/src/include/win/mman.h' \
		'!' -path 'native_client/src/trusted/service_runtime/win/debug_exception_handler.h' \
		'!' -path 'native_client/src/trusted/service_runtime/win/exception_patch/ntdll_patch.h' \
		'!' -path 'remoting/tools/verify_resources.py' \
		'!' -path 'sandbox/win/src/sandbox_types.h' \
		'!' -path 'third_party/WebKit/Source/WebKit/chromium/public/mac/WebSubstringUtil.h' \
		'!' -path 'third_party/cld/encodings/compact_lang_det/win/cld_*.cc' \
		'!' -path 'third_party/cld/encodings/compact_lang_det/win/cld_*.h' \
		'!' -path 'third_party/cros_system_api/dbus/*.proto' \
		'!' -path 'third_party/cros_system_api/dbus/service_constants.h' \
		'!' -path 'third_party/sfntly/cpp/src/sample/chromium/*' \
		'!' -path 'third_party/tcmalloc/chromium/*' \
		'!' -path 'third_party/v8-i18n/tools/js2c.py' \
		'!' -path 'ui/base/win/dpi.h' \
		'!' -path 'v8/tools/js2c.py' \
		'!' -path 'v8/tools/jsmin.py' \
		'!' -path 'webkit/tools/test_shell/*.h' \
		')' \
	-print -delete
}

# There are directories we want to strip, but that are unnecessarily required by the build-system
# So we drop everything but the gyp/gypi files
almost_strip_dirs() {
	local dir
	for dir in \
		breakpad_ \
		build/ios \
		courgette \
		third_party/cros_dbus_cplusplus \
		; do
		find $dir -depth -mindepth 1 '!' '(' -name '*.gyp' -o -name '*.gypi' ')' -print -delete || :
	done

	find tools -type f \
		'!' -iname '*.gyp*' \
		'!' -path 'tools/build/*' \
		'!' -path 'tools/clang/scripts/plugin_flags.sh' \
		'!' -path 'tools/compile_test/compile_test.py' \
		'!' -path 'tools/generate_library_loader/*' \
		'!' -path 'tools/generate_shim_headers/generate_shim_headers.py' \
		'!' -path 'tools/generate_stubs/*' \
		'!' -path 'tools/grit/*' \
		'!' -path 'tools/gritsettings/*' \
		'!' -path 'tools/gyp/*' \
		'!' -path 'tools/json_comment_eater.py' \
		'!' -path 'tools/json_schema_compiler/*' \
		'!' -path 'tools/json_to_struct/*' \
		'!' -path 'tools/licenses.py' \
		'!' -path 'tools/protoc_wrapper/*' \
		'!' -path 'tools/usb_ids/*' \
		'!' -path 'tools/uuidgen.py' \
		'!' -path 'tools/zip2msi.py' \
		-print -delete
}

# clean third party
# list based from archlinux PKGBUILD
# https://aur.archlinux.org/packages/ch/chromium-dev/PKGBUILD
clean_third_party() {
	local dir
	for dir in \
		third_party/ashmem \
		third_party/eyesfree \
		third_party/guava \
		third_party/iaccessible2 \
		third_party/icon_family \
		third_party/isimpledom \
		third_party/jsr-305 \
		third_party/libexif \
		third_party/mach_override \
		third_party/npapi/npspy \
		third_party/re2/benchlog \
		third_party/snappy \
		third_party/sqlite/*.patch \
		third_party/sqlite/src/*.patch \
		third_party/sudden_motion_sensor \
		; do
		rm -vfr "$dir"
	done

	find third_party -type f \
		'!' -iname '*.gyp*' \
		\! -path 'third_party/WebKit/*' \
		\! -path 'third_party/adobe/flash/*' \
		\! -path 'third_party/angle/include/EGL/*' \
		\! -path 'third_party/angle/include/GLSLANG/*' \
		\! -path 'third_party/angle/src/common/*' \
		\! -path 'third_party/angle/src/compiler/*' \
		\! -path 'third_party/angle/src/third_party/compiler/*' \
		\! -path 'third_party/cacheinvalidation/*' \
		\! -path 'third_party/cld/*' \
		\! -path 'third_party/cros_system_api/*' \
		\! -path 'third_party/flot/*.js' \
		\! -path 'third_party/hunspell/*' \
		\! -path 'third_party/hyphen/*' \
		\! -path 'third_party/iccjpeg/*' \
		\! -path 'third_party/jstemplate/*' \
		\! -path 'third_party/khronos/*' \
		\! -path 'third_party/leveldatabase/*' \
		\! -path 'third_party/libXNVCtrl/*' \
		\! -path 'third_party/libjingle/*' \
		\! -path 'third_party/libphonenumber/*' \
		\! -path 'third_party/libva/*' \
		\! -path 'third_party/libvpx/*' \
		\! -path 'third_party/libxml/chromium/*' \
		\! -path 'third_party/libyuv/*' \
		\! -path 'third_party/lss/*.h' \
		\! -path 'third_party/mesa/MesaLib/include/GL/gl.h' \
		\! -path 'third_party/mesa/MesaLib/include/GL/glext.h' \
		\! -path 'third_party/mesa/MesaLib/include/GL/glx.h' \
		\! -path 'third_party/mesa/MesaLib/include/GL/glxext.h' \
		\! -path 'third_party/mesa/MesaLib/include/GL/osmesa.h' \
		\! -path 'third_party/modp_b64/*' \
		\! -path 'third_party/mt19937ar/*' \
		\! -path 'third_party/npapi/*' \
		\! -path 'third_party/ots/*' \
		\! -path 'third_party/protobuf/*' \
		\! -path 'third_party/qcms/*' \
		\! -path 'third_party/re2/*' \
		\! -path 'third_party/sfntly/*' \
		\! -path 'third_party/skia/*' \
		\! -path 'third_party/smhasher/*' \
		\! -path 'third_party/sqlite/*' \
		\! -path 'third_party/tcmalloc/*' \
		\! -path 'third_party/trace-viewer/*' \
		\! -path 'third_party/undoview/*' \
		\! -path 'third_party/v8-i18n/*' \
		\! -path 'third_party/v8/*' \
		\! -path 'third_party/webrtc/*' \
		\! -path 'third_party/widevine/*' \
		\! -path 'third_party/x86inc/*' \
		-print -delete

	rm -vf third_party/expat/files/lib/expat.h
}

# parts based on ubuntu debian/rules
# http://bazaar.launchpad.net/~chromium-team/chromium-browser/chromium-browser.head/view/head:/debian/rules
remove_bin_only() {
	find -type f \( \
		-iname \*.exe -o \
		-iname \*.nexe -o \
		-iname \*.fon -o \
		-iname \*.ttf  -o \
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

		find $dir -depth -mindepth 1 \! \( -name '*.gyp' -o -name '*.gypi' -o -path $dir/$lib.h \) -print -delete
	done
}

# remove test data and files
# some scanned with find -name tests -o -name test -o -name test_data -o name testdata
# and find -iname *test*
remove_tests() {
	local dir

	# full remove
	for dir in \
	ash/test \
	base/test \
	breakpad/src/client/windows/tests \
	breakpad/src/common/linux/tests \
	breakpad/src/common/tests \
	cc/test \
	chrome/browser/chromeos/bluetooth/test \
	chrome/browser/component_updater/test \
	chrome/browser/extensions/api/test_ \
	chrome/browser/printing/cloud_print/test \
	chrome/browser/resources/gaia_auth/test \
	chrome/browser/resources/tracing/tests \
	chrome/browser/sync/test \
	chrome/browser/ui/cocoa/test \
	chrome/browser/ui/gtk/test \
	chrome/browser/ui/tests \
	chrome/browser/ui/views/test \
	chrome/installer/test \
	chrome/test/chromeos \
	chrome/test/data/firefox2_nss_mac \
	chrome/test/data/safe_browsing/old \
	chrome/test/logging/win \
	chrome/test/pyautolib/chromeos \
	chrome/test/webdriver/test \
	chrome/test_ \
	chrome/tools/test \
	chrome_frame/test \
	chrome_frame/tools/test \
	content/browser/worker_host/test \
	content/common/gpu/testdata \
	content/public/test \
	content/test \
	courgette/testdata \
	device/bluetooth/test \
	device/test \
	gpu/command_buffer/tests \
	media/test \
	media/tools/layout_tests/test_data \
	native_client/buildbot \
	native_client/src/shared/platform/testdata \
	native_client/src/trusted/gio/testdata \
	native_client/src/trusted/interval_multiset/testdata \
	native_client/src/trusted/service_runtime/testdata \
	native_client/src/trusted/validator/x86/decoder/generator/testdata \
	native_client/src/trusted/validator/x86/testing \
	native_client/src/trusted/validator_arm/testdata \
	native_client/src/trusted/validator_mips/testdata \
	native_client/src/trusted/validator_x86/testdata \
	native_client/tests \
	native_client/tools/testdata \
	native_client/tools/tests \
	native_client_sdk/src/build_tools/tests \
	native_client_sdk/src/libraries/c_salt/test \
	net/test \
	o3d/tests \
	ppapi/native_client/tests \
	ppapi/tests \
	printing/test \
	rlz/test \
	sandbox/linux/seccomp-legacy/tests \
	sandbox/linux/tests \
	sandbox/tests \
	sandbox/win/tests \
	sdch/open-vcdiff/testdata \
	seccompsandbox/tests \
	sync/internal_api/public/test \
	sync/internal_api/test \
	sync/test \
	testing/android \
	testing/gmock/scripts/test \
	testing/gmock/test \
	testing/gtest/scripts/test \
	testing/gtest/test \
	third_party/WebKit/LayoutTests \
	third_party/WebKit/Source/JavaScriptCore/API/tests \
	third_party/WebKit/Source/JavaScriptCore/qt/tests \
	third_party/WebKit/Source/JavaScriptCore/tests \
	third_party/WebKit/Source/ThirdParty/gtest/scripts/test \
	third_party/WebKit/Source/ThirdParty/gtest/test \
	third_party/WebKit/Source/ThirdParty/gyp/test \
	third_party/WebKit/Source/ThirdParty/qunit/test \
	third_party/WebKit/Source/WebCore/bindings/scripts/test \
	third_party/WebKit/Source/WebCore/testing_ \
	third_party/WebKit/Source/WebKit/chromium/tests \
	third_party/WebKit/Source/WebKit/efl/tests \
	third_party/WebKit/Source/WebKit/gtk/tests \
	third_party/WebKit/Source/WebKit/qt/tests \
	third_party/WebKit/Source/WebKit2/UIProcess/API/efl/tests \
	third_party/WebKit/Source/WebKit2/UIProcess/API/gtk/tests \
	third_party/WebKit/Source/WebKit2/UIProcess/API/qt/tests \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/Tests/mac \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/Tests/win \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/mac \
	third_party/WebKit/Tools/DumpRenderTree/TestNetscapePlugIn/win \
	third_party/WebKit/Tools/Scripts/webkitpy/test \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/TestWebKitAPI/mac \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/WebKit/win \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/WebKit2/mac \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/WebKit2/win \
	third_party/WebKit/Tools/TestWebKitAPI/Tests/mac \
	third_party/WebKit/Tools/TestWebKitAPI/mac \
	third_party/WebKit/Tools/TestWebKitAPI/win \
	third_party/angle/tests \
	third_party/cacheinvalidation/files/src/google/cacheinvalidation/test \
	third_party/cacheinvalidation/src/google/cacheinvalidation/test \
	third_party/cacheinvalidation/src/java/com/google/ipc/invalidation/testing \
	third_party/cacheinvalidation/src/java/com/google/ipc/invalidation/testing/android \
	third_party/ffmpeg/tests \
	third_party/harfbuzz/tests \
	third_party/hunspell/tests \
	third_party/hyphen/tests \
	third_party/libexif/sources/test \
	third_party/libjingle/source/talk/app/webrtc/test \
	third_party/libjingle/source/talk/media/testdata \
	third_party/libphonenumber/src/resources/test \
	third_party/libphonenumber/src/test \
	third_party/libsrtp/srtp/crypto/test \
	third_party/libsrtp/srtp/test \
	third_party/libyuv/unit_test/testdata \
	third_party/mesa/MesaLib/src/gallium/tests \
	third_party/openssl/openssl/crypto/des/t/test \
	third_party/openssl/openssl/test \
	third_party/ots/test \
	third_party/protobuf/src/google/protobuf/testdata \
	third_party/protobuf/src/google/protobuf/testing \
	third_party/re2/re2/testing \
	third_party/safe_browsing/testing \
	third_party/sfntly/cpp/src/test \
	third_party/sqlite/src/test \
	third_party/sqlite/test \
	third_party/talloc/libreplace/test \
	third_party/tcmalloc/chromium/src/tests \
	third_party/tcmalloc/vendor/src/tests \
	third_party/tlslite/test \
	third_party/trace-viewer/test_data \
	third_party/trace-viewer/third_party/pywebsocket/src/test \
	third_party/trace-viewer/third_party/pywebsocket/src/test/testdata \
	third_party/v8-i18n/tests \
	third_party/webdriver/pylib/test \
	third_party/webdriver/test_data \
	third_party/webrtc/modules/audio_device/test/android \
	third_party/webrtc/modules/audio_processing/test/android \
	third_party/webrtc/modules/utility/test \
	third_party/webrtc/modules/video_capture/main/test/android \
	third_party/webrtc/system_wrappers/test \
	third_party/webrtc/test/manual \
	third_party/webrtc/test/testsupport/mac \
	third_party/webrtc/video_engine/test/android \
	third_party/webrtc/video_engine/test/auto_test/android \
	third_party/webrtc/voice_engine/test/android \
	third_party/xdg-utils/tests \
	third_party/yasm/source/patched-yasm/libyasm/tests \
	third_party/yasm/source/patched-yasm/modules/arch/lc3b/tests \
	third_party/yasm/source/patched-yasm/modules/arch/x86/tests \
	third_party/yasm/source/patched-yasm/modules/dbgfmts/dwarf2/tests \
	third_party/yasm/source/patched-yasm/modules/dbgfmts/stabs/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/bin/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/coff/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/elf/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/macho/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/rdf/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/win32/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/win64/tests \
	third_party/yasm/source/patched-yasm/modules/objfmts/xdf/tests \
	third_party/yasm/source/patched-yasm/modules/parsers/gas/tests \
	third_party/yasm/source/patched-yasm/modules/parsers/nasm/tests \
	third_party/yasm/source/patched-yasm/modules/parsers/tasm/tests \
	third_party/yasm/source/patched-yasm/modules/preprocs/nasm/tests \
	third_party/yasm/source/patched-yasm/modules/preprocs/raw/tests \
	third_party/yasm/source/patched-yasm/tools/python-yasm/tests \
	tools/clang/plugins/tests \
	tools/grit/grit/testdata \
	tools/gyp/test \
	tools/gyp/tools/emacs/testdata \
	tools/page_cycler/webpagereplay/tests \
	tools/perf_expectations/tests \
	tools/swarm_client/tests \
	ui/app_list/test \
	ui/aura/test \
	ui/base/test \
	ui/compositor/test \
	ui/gfx/test \
	ui/test \
	ui/views/test \
	v8/test \
	webkit/compositor_bindings/test \
	webkit/data/layout_tests \
	webkit/plugins/npapi/test \
	webkit/tools/test/reference_build \
	webkit/tools/test_shell/mac \
	; do
		rm -vfr "$dir"
	done

	# partial remove (keep .gyp)
	for dir in \
		chrome/browser/nacl_host/test \
		chrome/test/data \
		testing \
		third_party/webrtc/modules/audio_coding/codecs/cng/test \
		third_party/webrtc/modules/audio_coding/codecs/g711/test \
		third_party/webrtc/modules/audio_coding/codecs/g722/test \
		third_party/webrtc/modules/audio_coding/codecs/ilbc/test \
		third_party/webrtc/modules/audio_coding/codecs/isac/fix/test \
		third_party/webrtc/modules/audio_coding/codecs/isac/main/test \
		third_party/webrtc/modules/audio_coding/main/test \
		third_party/webrtc/modules/audio_coding/neteq/test \
		third_party/webrtc/modules/audio_conference_mixer/test \
		third_party/webrtc/modules/audio_device/test \
		third_party/webrtc/modules/audio_processing/test \
		third_party/webrtc/modules/rtp_rtcp/test \
		third_party/webrtc/modules/udp_transport/test \
		third_party/webrtc/modules/video_capture/main/test \
		third_party/webrtc/modules/video_coding/codecs/test \
		third_party/webrtc/modules/video_coding/codecs/vp8/test \
		third_party/webrtc/modules/video_coding/main/test \
		third_party/webrtc/modules/video_processing/main/test \
		third_party/webrtc/modules/video_render/main/test \
		third_party/webrtc/video_engine/test \
		third_party/webrtc/voice_engine/test \
		tools/json_schema_compiler/test \
		; do
		find $dir -depth -mindepth 1 '!' '(' -name '*.gyp' -o -name '*.gypi' ')' -print -delete || :
	done

	# link headers from system dir. too many files to patch, we don't even build tests
	install -d testing/gtest/include
	ln -s /usr/include/gtest testing/gtest/include/gtest

	# delete unittest files
	find . '(' \
		-name '*_unittest*.*' \
		-o -name '*_unittest.*' \
		-o -name '*_unittest' \
		-o -name 'test_*.*' \
		-o -name '*_test.*' \
	')' '!' -name '*.gyp*' \
		'!' -name '*.isolate' \
		'!' -name '*.grd' \
		'!' -path './chrome/browser/diagnostics/diagnostics_test.*' \
		'!' -path './chrome/browser/extensions/api/declarative/test_rules_registry.*' \
		'!' -path './chrome/browser/extensions/api/test/test_api.*' \
		'!' -path './chrome/browser/resources/net_internals/*' \
		'!' -path './chrome/browser/ui/webui/test_chrome_web_ui_controller_factory*' \
		'!' -path './chrome/common/net/test_server_locations.*' \
		'!' -path './chrome/renderer/resources/extensions/test_custom_bindings.js' \
		'!' -path './chrome/test/base/test_switches.*' \
		'!' -path './chrome/test/perf/browser_perf_test.*' \
		'!' -path './chrome/test/perf/perf_test.*' \
		'!' -path './native_client/src/trusted/fault_injection/test_injection.*' \
		'!' -path './native_client/src/trusted/service_runtime/env_cleanser_test.h' \
		'!' -path './net/base/test_completion_callback.*' \
		'!' -path './net/base/test_data_stream.*' \
		'!' -path './net/base/test_root_certs*' \
		'!' -path './remoting/base/resources_unittest.*' \
		'!' -path './third_party/skia/src/gpu/gr_unittests.*' \
		'!' -path './tools/compile_test/compile_test.py' \
		'!' -path './ui/compositor/test_web_graphics_context_3d.*' \
		'!' -path './webkit/fileapi/test_mount_point_provider.*' \
		'!' -path './webkit/gpu/test_context_provider_factory.*' \
		'!' -path './webkit/support/test_webkit_platform_support.h' \
		'!' -path './webkit/tools/test_shell/*.h' \
	-print -delete || :
}

remove_nonessential_dirs > REMOVED-nonessential_dirs.txt
almost_strip_dirs > REMOVED-stripped.txt
remove_bin_only > REMOVED-bin_only.txt
remove_tests > REMOVED-tests.txt

strip_system_dirs \
	native_client/src/third_party_mod/jsoncpp \
	third_party/bzip2 \
	third_party/ffmpeg \
	third_party/flac \
	third_party/icu \
	third_party/jsoncpp \
	third_party/libXNVCtrl \
	third_party/libevent \
	third_party/libexif \
	third_party/libjpeg \
	third_party/libmtp \
	third_party/libpng \
	third_party/libsrtp \
	third_party/libusb \
	third_party/libvpx \
	third_party/libwebp \
	third_party/libxslt \
	third_party/mesa \
	third_party/opus \
	third_party/protobuf \
	third_party/re2 \
	third_party/speex \
	third_party/yasm \
	third_party/zlib \
	v8 \
> REMOVED-system_dirs.txt

clean_third_party > REMOVED-third_party.txt

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

if [ "${emptydirs:-0}" != "0" ]; then
	# cleanup empty dirs
	find -type d '!' -name '.' -print0 | sort -zr | xargs -0 rmdir --ignore-fail-on-non-empty > REMOVED-dirs.txt
fi

# report what's in them
for a in REMOVED-*.txt; do
	cat $a
done
