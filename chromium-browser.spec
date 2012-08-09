#
# Conditional build:
%bcond_without	debuginfo		# disable debuginfo creation (it is huge)
%bcond_without	ffmpegsumo		# build with ffmpegsumo
%bcond_without	kerberos		# build with kerberos support (dlopened if support compiled, library names in src/net/http/http_auth_gssapi_posix.cc)
%bcond_without	keyring 		# with keyring support (gnome-keyring dlopened, kwalletd via dbus)
%bcond_without	cups			# with cups
%bcond_without	gconf			# with GConf
%bcond_without	pulseaudio		# with pulseaudio
%bcond_without	nacl			# build Native Client support
%bcond_without	sandboxing		# with sandboxing
%bcond_with		selinux			# with SELinux (need policy first)
%bcond_with		shared_libs		# with shared libs
%bcond_with		sse2			# use SSE2 instructions
%bcond_with		tcmalloc		# use tcmalloc
%bcond_with		system_sqlite	# with system sqlite
%bcond_without	system_flac		# with system flac
%bcond_without	system_libwebp	# with system libwebp
%bcond_without	system_speex	# with system speex
%bcond_with		system_v8		# with system v8
%bcond_without	system_vpx		# with system vpx
%bcond_without	system_yasm		# with system yasm
%bcond_without	system_zlib		# with system zlib
%bcond_without	libjpegturbo	# use libjpeg-turbo features
%bcond_with		verbose			# verbose build (V=1)

# TODO
# - check system sqlite linking problems
# - find system deps: find -name '*.gyp*' | xargs grep 'use_system.*=='
# - use_system_ssl (use_openssl: http://crbug.com/62803)
# - use_system_ffmpeg && build_ffmpegsumo
# - use_system_hunspell
# - use_system_stlport
# - other defaults: src/build/common.gypi

# NOTES:
# - mute BEEP mixer if you do not want to hear horrible system bell when
#   pressing home/end in url bar or more ^F search results on page.
# - build -bp: 1.2G
# - build i686: -bc: 2.7G; -bb: ~1.0GB
# - build x86_64: ~1.9G
# - http://code.google.com/p/chromium/wiki/LinuxBuildInstructionsPrerequisites
# - to look for new tarball, use update-source.sh script

# NOTE TO USERS:
# To use chromium nightly builds for pld-th save to /etc/poldek/repos.d (as chromium-nightly.conf):
# http://carme.pld-linux.org/~glen/chromium-browser/th/i686/chromium-nightly.conf
# or:
# http://carme.pld-linux.org/~glen/chromium-browser/th/x86_64/chromium-nightly.conf

%define		gyp_rev	1014
Summary:	A WebKit powered web browser
Name:		chromium-browser
Version:	21.0.1180.75
Release:	1
License:	BSD, LGPL v2+ (ffmpeg)
Group:		X11/Applications/Networking
Source0:	http://carme.pld-linux.org/~glen/chromium-browser/src/stable/%{name}-%{version}.tar.xz
# Source0-md5:	ab9d8305aed422608d73cb342ee5abcf
Source1:	%{name}.default
Source2:	%{name}.sh
Source3:	%{name}.desktop
Source5:	find-lang.sh
Source6:	update-source.sh
Source7:	clean-source.sh
Source8:	get-source.sh
Patch0:		system-libs.patch
Patch1:		plugin-searchdirs.patch
Patch2:		gyp-system-minizip.patch
Patch3:		disable_dlog_and_dcheck_in_release_builds.patch
Patch4:		path-libpdf.patch
Patch5:		options-support.patch
Patch6:		get-webkit_revision.patch
Patch7:		dlopen_sonamed_gl.patch
Patch8:		chromium_useragent.patch.in
Patch9:		chromium-ppapi.patch
# https://bugs.gentoo.org/show_bug.cgi?id=393471
# libjpeg-turbo >= 1.1.90 supports that feature
Patch11:	chromium-revert-jpeg-swizzle-r2.patch
Patch15:	nacl-build-irt.patch
Patch16:	nacl-linkingfix.patch
URL:		http://www.chromium.org/Home
%{?with_gconf:BuildRequires:	GConf2-devel}
BuildRequires:	OpenGL-GLU-devel
BuildRequires:	alsa-lib-devel
BuildRequires:	atk-devel
BuildRequires:	bison
BuildRequires:	bzip2-devel
%{?with_nacl:BuildRequires:	crossnacl-binutils >= 2.20.1}
%{?with_nacl:BuildRequires:	crossnacl-gcc >= 4.4.3}
%{?with_nacl:BuildRequires:	crossnacl-gcc-c++ >= 4.4.3}
%{?with_nacl:BuildRequires:	crossnacl-newlib >= 1.18.0}
%{?with_cups:BuildRequires:	cups-devel}
BuildRequires:	dbus-glib-devel
BuildRequires:	expat-devel
%{?with_system_flac:BuildRequires:	flac-devel}
BuildRequires:	flex
BuildRequires:	fontconfig-devel
BuildRequires:	glib2-devel
BuildRequires:	gperf
BuildRequires:	gtk+2-devel
%{?with_kerberos:BuildRequires:	heimdal-devel}
BuildRequires:	hicolor-icon-theme
BuildRequires:	libevent-devel
%{?with_keyring:BuildRequires:	libgnome-keyring-devel}
BuildRequires:	libicu-devel >= 4.6
%{!?with_libjpegturbo:BuildRequires:	libjpeg-devel}
%{?with_libjpegturbo:BuildRequires:	libjpeg-turbo-devel >= 1.2.0}
BuildRequires:	libpng-devel
%{?with_selinux:BuildRequires:	libselinux-devel}
BuildRequires:	libstdc++-devel
%{?with_system_vpx:BuildRequires:	libvpx-devel >= 0.9.5-2}
%{?with_system_libwebp:BuildRequires:	libwebp-devel >= 0.1.99}
BuildRequires:	libxml2-devel
BuildRequires:	libxslt-devel
BuildRequires:	lzma
BuildRequires:	minizip-devel
BuildRequires:	nspr-devel
BuildRequires:	nss-devel >= 1:3.12.3
BuildRequires:	pam-devel
BuildRequires:	pango-devel
BuildRequires:	perl-modules
BuildRequires:	pkgconfig
%{?with_pulseaudio:BuildRequires:	pulseaudio-devel}
BuildRequires:	python
#BuildRequires:	python-gyp >= 1-%{gyp_rev}
BuildRequires:	python-modules
BuildRequires:	rpm >= 4.4.9-56
BuildRequires:	rpmbuild(macros) >= 1.453
%{?with_system_speex:BuildRequires:	speex-devel >= 1:1.2-rc1}
BuildRequires:	sqlite3-devel >= 3.6.1
BuildRequires:	subversion
BuildRequires:	tar >= 1:1.22
BuildRequires:	udev-devel
BuildRequires:	util-linux
%{?with_system_v8:BuildRequires:	v8-devel >= 3.7}
BuildRequires:	which
BuildRequires:	xorg-lib-libXScrnSaver-devel
BuildRequires:	xorg-lib-libXt-devel
BuildRequires:	xorg-lib-libXtst-devel
BuildRequires:	xz
%{?with_system_yasm:BuildRequires:	yasm}
%{?with_system_zlib:BuildRequires:	zlib-devel}
Requires:	browser-plugins >= 2.0
Requires:	desktop-file-utils
Requires:	hicolor-icon-theme
%{?with_libjpegturbo:Requires:	libjpeg-turbo >= 1.2.0}
%{?with_system_vpx:Requires:	libvpx >= 0.9.5-2}
Requires:	xdg-utils >= 1.0.2-4
Provides:	wwwbrowser
Obsoletes:	chromium-browser-bookmark_manager < 5.0.388.0
Obsoletes:	chromium-browser-inspector < 15.0.863.0
ExclusiveArch:	%{ix86} %{x8664} arm
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		find_lang 	sh find-lang.sh %{buildroot}
# Usage: gyp_with BCOND_NAME [OPTION_NAME]
%define		gyp_with() %{expand:%%{?with_%{1}:-D%{?2:use_%{2}}%{!?2:use_%{1}}=1}%%{!?with_%{1}:-D%{?2:use_%{2}}%{!?2:use_%{1}}=0}}

%if %{without debuginfo}
%define		_enable_debug_packages	0
%endif

%description
Chromium is an open-source browser project that aims to build a safer,
faster, and more stable way for all Internet users to experience the
web.

Chromium serves as a base for Google Chrome, which is Chromium
rebranded (name and logo) with very few additions such as usage
tracking and an auto-updater system.

%package l10n
Summary:	chromium-browser language packages
Group:		I18n
Requires:	%{name} = %{version}-%{release}

%description l10n
Chromium is an open-source browser project that aims to build a safer,
faster, and more stable way for all Internet users to experience the
web.

This package contains language packages for 50 languages:

ar, bg, bn, ca, cs, da, de, el, en-GB, es-LA, es, et, fi, fil, fr, gu,
he, hi, hr, hu, id, it, ja, kn, ko, lt, lv, ml, mr, nb, nl, or, pl,
pt-BR, pt-PT, ro, ru, sk, sl, sr, sv, ta, te, th, tr, uk, vi, zh-CN,
zh-TW

%prep
%setup -q

# Google's versioning is interesting. They never reset "BUILD", which is how we jumped
# from 3.0.201.0 to 4.0.202.0 as they moved to a new major branch
. ./src/chrome/VERSION
ver=$MAJOR.$MINOR.$BUILD.$PATCH
test "$ver" = %{version}

gyp_rev=$(grep googlecode_url.*gyp src/DEPS | cut -d'"' -f6 | cut -d@ -f2)
test "$gyp_rev" = %{gyp_rev} || :

v8_ver=$(awk 'NR=1 {print $NF; exit}' src/v8/ChangeLog || :)

# Populate the LASTCHANGE file template as we no longer have the VCS files at this point
#echo "%{svnver}" > src/build/LASTCHANGE.in

# add chromium and pld to useragent
%define pld_version %(echo %{pld_release} | sed -e 'y/[at]/[AT]/')
sed -e 's/@BUILD_DIST@/PLD %{pld_version}/g' \
    -e 's/@BUILD_DIST_NAME@/PLD/g' \
    -e 's/@BUILD_DIST_VERSION@/%{pld_version}/g' \
    < %{PATCH8} | %{__patch} -p1

%{__sed} -e 's,@localedir@,%{_libdir}/%{name},' %{SOURCE5} > find-lang.sh
ln -s %{SOURCE7} src

%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p1
%patch6 -p1
%patch7 -p1
cd src
%patch9 -p0
%{!?with_libjpegturbo:%patch11 -p0}
%patch15 -p1
%patch16 -p1
cd ..

cd src
sh -x clean-source.sh %{!?with_system_v8:v8=0} %{!?with_nacl:nacl=0} libxml=0

%build
cd src

%if %{with nacl}
rm -rf native_client/toolchain/linux_x86_newlib
# Make symlinks for nacl
cd native_client/toolchain
install -d linux_x86_newlib/x86_64-nacl/bin
install -d linux_x86_newlib/x86_64-nacl/lib
install -d linux_x86_newlib/x86_64-nacl/lib32
install -d linux_x86_newlib/x86_64-nacl/nacl/include/bits
install -d linux_x86_newlib/x86_64-nacl/nacl/include/machine
install -d linux_x86_newlib/x86_64-nacl/nacl/include/sys
# link newlib toolchain to glibc as well, see gentoo bug #417019
#ln -s linux_x86_newlib linux_x86
cd linux_x86_newlib/x86_64-nacl/bin
ln -s %{_bindir}/x86_64-nacl-gcc gcc
ln -s %{_bindir}/x86_64-nacl-g++ g++
ln -s %{_bindir}/x86_64-nacl-ar ar
ln -s %{_bindir}/x86_64-nacl-as as
ln -s %{_bindir}/x86_64-nacl-ranlib ranlib
ln -s %{_bindir}/x86_64-nacl-strip x86-64-nacl-strip
ln -s %{_bindir}/x86_64-nacl-strip strip
ln -s %{_prefix}/x86_64-nacl/lib/*.a ../lib/
ln -s %{_prefix}/x86_64-nacl/lib/32/*.a ../lib32/
cd ../nacl/include
for i in $(find %{_prefix}/x86_64-nacl/include -type f | grep -v "c++"); do
	ln -s $i ${i#%{_prefix}/x86_64-nacl/include/}
done
cd ../../../../../..
%endif

test -e Makefile || %{__python} build/gyp_chromium --format=make build/all.gyp \
%ifarch %{ix86}
	-Dtarget_arch=ia32 \
%endif
%ifarch %{x8664}
	-Dtarget_arch=x64 \
%endif
%if "%{cc_version}" >= "4.4.0" && "%{cc_version}" < "4.5.0"
	-Dno_strict_aliasing=1 -Dgcc_version=44 \
%endif
%if %{with sandboxing}
	-Dlinux_sandbox_path=%{_libdir}/%{name}/chromium-sandbox \
	-Dlinux_sandbox_chrome_path=%{_libdir}/%{name}/%{name} \
%endif
	%{!?debug:-Dwerror=} \
	%{!?debuginfo:-Dfastbuild=1 -Dremove_webcore_debug_symbols=1} \
	%{?with_shared_libs:-Dlibrary=shared_library} \
	-Dbuild_ffmpegsumo=%{?with_ffmpegsumo:1}%{!?with_ffmpegsumo:0} \
	-Dffmpeg_branding=Chrome \
	-Dproprietary_codecs=1 \
%if %{with nacl}
	%{?_:# Disable glibc Native Client toolchain, we don't need it (gentoo bug #417019).} \
	-Ddisable_glibc=1 \
%else
	-Ddisable_nacl=1 \
%endif
	%{!?with_sse2:-Ddisable_sse2=1} \
	%{?with_selinux:-Dselinux=1} \
	%{gyp_with cups} \
	%{gyp_with flac} \
	%{gyp_with gconf} \
	%{gyp_with kerberos} -Dlinux_link_kerberos=0 \
	%{gyp_with keyring gnome_keyring} -Dlinux_link_gnome_keyring=0 \
	%{gyp_with pulseaudio} \
	%{gyp_with system_libwebp} \
	%{gyp_with system_speex} \
	%{gyp_with system_sqlite} \
	%{gyp_with system_v8} \
	%{gyp_with system_vpx} \
	%{gyp_with system_yasm} \
	%{gyp_with system_zlib} \
	-Duse_system_bzip2=1 \
	-Duse_system_icu=1 \
	-Duse_system_libevent=1 \
	-Duse_system_libjpeg=1 \
	-Duse_system_libpng=1 \
	-Duse_system_libxml=1 \
	-Duse_system_libxslt=1 \
	-Duse_system_xdg_utils=1 \
	%{!?with_tcmalloc:-Dlinux_use_tcmalloc=0} \
	-Dlinux_use_gold_binary=0 \
	-Dlinux_use_gold_flags=0

%{__make} chrome %{?with_sandboxing:chrome_sandbox} \
	BUILDTYPE=%{!?debug:Release}%{?debug:Debug} \
	%{?with_verbose:V=1} \
	CC="%{__cc}" \
	CXX="%{__cxx}" \
	LDFLAGS="%{rpmldflags} -fuse-ld=gold" \
	CC.host="%{__cc}" \
	CXX.host="%{__cxx}" \
	LDFLAGS.host="%{rpmldflags}" \
	CFLAGS="%{rpmcflags} %{rpmcppflags}" \
	CXXFLAGS="%{rpmcxxflags} %{rpmcppflags}"

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_libdir}/%{name}/{themes,plugins,extensions} \
	$RPM_BUILD_ROOT{%{_bindir},%{_sysconfdir}/%{name},%{_mandir}/man1,%{_desktopdir}}

cd src/out/%{!?debug:Release}%{?debug:Debug}
cp -p %{SOURCE1} $RPM_BUILD_ROOT%{_sysconfdir}/%{name}/default
install -p %{SOURCE2} $RPM_BUILD_ROOT%{_bindir}/%{name}
%{__sed} -i -e 's,@libdir@,%{_libdir}/%{name},' $RPM_BUILD_ROOT%{_bindir}/%{name}
cp -a *.pak locales resources $RPM_BUILD_ROOT%{_libdir}/%{name}
cp -p chrome.1 $RPM_BUILD_ROOT%{_mandir}/man1/%{name}.1
install -p chrome $RPM_BUILD_ROOT%{_libdir}/%{name}/%{name}
install -p chrome_sandbox $RPM_BUILD_ROOT%{_libdir}/%{name}/chromium-sandbox
%if %{with ffmpegsumo}
install -p libffmpegsumo.so $RPM_BUILD_ROOT%{_libdir}/%{name}
%endif
cp -p %{SOURCE3} $RPM_BUILD_ROOT%{_desktopdir}

%{__rm} -r $RPM_BUILD_ROOT%{_libdir}/%{name}/resources/extension/demo

%if %{with nacl}
# Install Native Client files on platforms that support it.
install -p nacl_helper{,_bootstrap} $RPM_BUILD_ROOT%{_libdir}/%{name}
install -p libppGoogleNaClPluginChrome.so $RPM_BUILD_ROOT%{_libdir}/%{name}
%ifarch %{x8664}
install -p nacl_irt_x86_64.nexe $RPM_BUILD_ROOT%{_libdir}/%{name}
%endif
%ifarch %{ix86}
install -p nacl_irt_x86_32.nexe $RPM_BUILD_ROOT%{_libdir}/%{name}
%endif
%endif

cd -

for icon in src/chrome/app/theme/chromium/product_logo_[0-9]*.png; do
	size=${icon##*/product_logo_}
	size=${size%.png}

	# this will skip non-numeric (22_mono_invert, 22_mono)
	dir=%{_iconsdir}/hicolor/${size}x${size}/apps
	test -d "$dir" || continue

	install -d $RPM_BUILD_ROOT$dir
	cp -p $icon $RPM_BUILD_ROOT$dir/%{name}.png
done

%browser_plugins_add_browser %{name} -p %{_libdir}/%{name}/plugins -b <<'EOF'
# http://code.google.com/p/chromium/issues/detail?id=24507
gecko-mediaplayer*.so
EOF

# find locales
%find_lang %{name}.lang
# always package en-US
%{__sed} -i -e '/en-US.pak/d' %{name}.lang

%clean
rm -rf $RPM_BUILD_ROOT

%post
%update_icon_cache hicolor
%update_desktop_database
%update_browser_plugins

%postun
if [ "$1" = 0 ]; then
	%update_icon_cache hicolor
	%update_browser_plugins
fi

%files -f %{name}.lang
%defattr(644,root,root,755)
%{_browserpluginsconfdir}/browsers.d/%{name}.*
%config(noreplace) %verify(not md5 mtime size) %{_browserpluginsconfdir}/blacklist.d/%{name}.*.blacklist
%dir %{_sysconfdir}/%{name}
%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/%{name}/default
%attr(755,root,root) %{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*
%{_desktopdir}/*.desktop
%{_iconsdir}/hicolor/*/apps/%{name}.png
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/chrome.pak
%{_libdir}/%{name}/content_resources.pak
%{_libdir}/%{name}/resources.pak
%{_libdir}/%{name}/theme_resources_standard.pak
%{_libdir}/%{name}/ui_resources_standard.pak
%dir %{_libdir}/%{name}/locales
%{_libdir}/%{name}/locales/en-US.pak
%dir %{_libdir}/%{name}/resources
%{_libdir}/%{name}/resources/inspector
%dir %{_libdir}/%{name}/themes
%dir %{_libdir}/%{name}/extensions
%dir %{_libdir}/%{name}/plugins
%attr(755,root,root) %{_libdir}/%{name}/%{name}
# These unique permissions are intentional and necessary for the sandboxing
%attr(4555,root,root) %{_libdir}/%{name}/chromium-sandbox

# ffmpeg libs
%if %{with ffmpegsumo}
%attr(755,root,root) %{_libdir}/%{name}/libffmpegsumo.so
%endif

%if %{with nacl}
%attr(755,root,root) %{_libdir}/%{name}/libppGoogleNaClPluginChrome.so
%attr(755,root,root) %{_libdir}/%{name}/nacl_helper
%attr(755,root,root) %{_libdir}/%{name}/nacl_helper_bootstrap
%attr(755,root,root) %{_libdir}/%{name}/nacl_irt_x86_*.nexe
%endif

%files l10n -f %{name}.lang
%defattr(644,root,root,755)
