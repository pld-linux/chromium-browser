#
# Conditional build:
%bcond_without	cups			# with cups
%bcond_without	debuginfo		# disable debuginfo creation (it is huge)
%bcond_with	dev			# with dev optimizations (skip clean source)
%bcond_without	gconf			# with GConf
%bcond_without	kerberos		# build with kerberos support (dlopened if support compiled, library names in net/http/http_auth_gssapi_posix.cc)
%bcond_without	keyring 		# with keyring support (gnome-keyring dlopened, kwalletd via dbus)
%bcond_with		gps 			# with gps support (linked), if enabled must use exactly same gpsd as shm structures may change leading to unexpected results (crash)
%bcond_without	libjpegturbo	# use libjpeg-turbo features
%bcond_with	nacl			# build Native Client support, disabled: http://crbug.com/269560
%bcond_without	ninja			# use Ninja instead of make to build
%bcond_without	pulseaudio		# with pulseaudio
%bcond_without	sandboxing		# with sandboxing
%bcond_with		selinux			# with SELinux (need policy first)
%bcond_with		shared_libs		# with shared libs
%bcond_with		sse2			# use SSE2 instructions
%bcond_without	system_flac		# system flac
%bcond_with	system_ffmpeg	# system ffmpeg instead of ffmpegsumo
%bcond_without	system_harfbuzz	# system harfbuzz
%bcond_without	system_jsoncpp	# system jsoncpp
%bcond_without	system_libexif	# system libexif
%bcond_without	system_libmtp	# system libmtp
%bcond_with	system_libusb	# system libusb-1, disabled: http://crbug.com/266149
%bcond_without	system_libwebp	# system libwebp
%bcond_without	system_libxnvctrl	# system libxnvctrl
%bcond_with	system_mesa		# system Mesa
%bcond_without	system_minizip	# system minizip
%bcond_without	system_opus		# system opus codec support, http://www.opus-codec.org/examples/
%bcond_without	system_protobuf	# system protobuf
%bcond_without	system_re2		# system re2
%bcond_without	system_snappy	# system snappy
%bcond_without	system_speex	# system speex
%bcond_with	system_sqlite	# system sqlite WebSQL (http://www.w3.org/TR/webdatabase/) will not work
%bcond_without	system_libsrtp	# system srtp (can be used if using bundled libjingle)
%bcond_with		system_v8		# system v8
%bcond_with	system_libvpx	# system libvpx
%bcond_without	system_yasm		# system yasm
%bcond_without	system_zlib		# system zlib
%bcond_with	tcmalloc		# use tcmalloc
%bcond_without	verbose			# verbose build (V=1)

%ifarch %{ix86}
# GLsizeiptr different size, track: http://bugs.gentoo.org/457130
%undefine	with_system_mesa
%endif

# TODO
# - find system deps: find -type f -name '*.gyp*' | xargs grep -oh 'use_system_.*%' | sort -u
# - use_system_skia
# - use_system_ssl (use_openssl: http://crbug.com/62803)
# - use_system_stlport (android specific)
# - vpx: invert (remove) media_use_libvpx when libvpx with vp9 support is released

# NOTES:
# - mute BEEP mixer if you do not want to hear horrible system bell when
#   pressing home/end in url bar or more ^F search results on page.
# - space considerations:
#   - unpacked sources: ~490MiB
#   - built code: ~1.4GiB (x86_64/i686)
# - http://code.google.com/p/chromium/wiki/LinuxBuildInstructionsPrerequisites
# - to look for new tarball, use update-source.sh script

%define		branch		36.0.1985
%define		basever		143
#define		patchver	132
%define		gyp_rev	1014
Summary:	A WebKit powered web browser
Name:		chromium-browser
%if "%{?patchver}" != ""
Version:	%{branch}.%{patchver}
%else
Version:	%{branch}.%{basever}
%endif
Release:	0.1
License:	BSD%{!?with_system_ffmpeg:, LGPL v2+ (ffmpeg)}
Group:		X11/Applications/Networking
Source0:	http://carme.pld-linux.org/~glen/chromium-browser/src/stable/%{name}-%{branch}.%{basever}.tar.xz
# Source0-md5:	8180f26a32fec2f28ae0a2f9a25bdca2
%if "%{?patchver}" != ""
Patch0:		http://carme.pld-linux.org/~glen/chromium-browser/src/stable/%{name}-%{version}.patch.xz
# Patch0-md5:	4eafe1e64bd47a11dbfaf61a2dd50b6e
%endif
Source1:	%{name}.default
Source2:	%{name}.sh
Source3:	%{name}.desktop
Source5:	find-lang.sh
Source6:	update-source.sh
Source7:	clean-source.sh
Source8:	get-source.sh
Source9:	master_preferences.json
Patch2:		enable-video-decode-accel.patch
Patch4:		path-libpdf.patch
Patch7:		dlopen_sonamed_gl.patch
Patch8:		chromium_useragent.patch.in
# https://bugs.gentoo.org/show_bug.cgi?id=393471
# libjpeg-turbo >= 1.1.90 supports that feature
Patch11:	chromium-revert-jpeg-swizzle-r2.patch
Patch15:	nacl-build-irt.patch
Patch16:	nacl-linkingfix.patch
Patch18:	nacl-no-untar.patch
Patch24:	nacl-verbose.patch
Patch25:	gnome3-volume-control.patch
Patch26:	master-prefs-path.patch
Patch28:	system-mesa.patch
Patch30:	system-ply.patch
Patch31:	system-jinja.patch
Patch32:	remove_bundled_libraries-stale.patch
Patch35:	etc-dir.patch
URL:		http://www.chromium.org/Home
%{?with_gconf:BuildRequires:	GConf2-devel}
%{?with_system_mesa:BuildRequires:	Mesa-libGL-devel >= 9.1}
BuildRequires:	Mesa-libGLES-devel >= 9.1
%{?with_system_mesa:BuildRequires:	Mesa-libGLU-devel}
%{?with_system_mesa:BuildRequires:	Mesa-libOSMesa-devel >= 9.1}
BuildRequires:	alsa-lib-devel
BuildRequires:	atk-devel
BuildRequires:	bison
BuildRequires:	bzip2-devel
%{?with_nacl:BuildRequires:	crossnacl-binutils >= 2.20.1}
%{?with_nacl:BuildRequires:	crossnacl-gcc >= 4.4.3}
%{?with_nacl:BuildRequires:	crossnacl-gcc-c++ >= 4.4.3}
%{?with_nacl:BuildRequires:	crossnacl-newlib >= 1.20.0-3}
%{?with_cups:BuildRequires:	cups-devel}
BuildRequires:	elfutils-devel
BuildRequires:	expat-devel
%{?with_system_ffmpeg:BuildRequires:	ffmpeg-devel >= 1.0}
%{?with_system_flac:BuildRequires:	flac-devel >= 1.2.1-7}
BuildRequires:	fontconfig-devel
BuildRequires:	glib2-devel
BuildRequires:	gperf
%{?with_gps:BuildRequires:	gpsd-devel}
BuildRequires:	gtest-devel
BuildRequires:	gtk+2-devel
%{?with_system_harfbuzz:BuildRequires:	harfbuzz-devel}
%{?with_system_harfbuzz:BuildRequires:	harfbuzz-icu-devel}
%{?with_kerberos:BuildRequires:	heimdal-devel}
BuildRequires:	hicolor-icon-theme
%{?with_system_jsoncpp:BuildRequires:	jsoncpp-devel}
%{?with_system_libxnvctrl:BuildRequires:	libXNVCtrl-devel >= 310.19}
BuildRequires:	libevent-devel
%{?with_system_libexif:BuildRequires:	libexif-devel >= 1:0.6.21}
%{?with_keyring:BuildRequires:	libgnome-keyring-devel}
BuildRequires:	libicu-devel >= 4.6
%{!?with_libjpegturbo:BuildRequires:	libjpeg-devel}
%{?with_libjpegturbo:BuildRequires:	libjpeg-turbo-devel >= 1.2.0}
%{?with_system_libmtp:BuildRequires:	libmtp-devel >= 1.1.3}
BuildRequires:	libpng-devel
%{?with_selinux:BuildRequires:	libselinux-devel}
BuildRequires:	libstdc++-devel
%{?with_system_libusb:BuildRequires:	libusb-devel >= 1.0}
%{?with_system_libvpx:BuildRequires:	libvpx-devel >= 1.3.0}
%{?with_system_libwebp:BuildRequires:	libwebp-devel >= 0.4.0}
BuildRequires:	libxml2-devel
BuildRequires:	libxslt-devel
BuildRequires:	man-db
%{?with_system_minizip:BuildRequires:	minizip-devel}
%{?with_ninja:BuildRequires:	ninja >= 1.3.0}
BuildRequires:	nspr-devel
BuildRequires:	nss-devel >= 1:3.12.3
%{?with_system_opus:BuildRequires:	opus-devel >= 1.0.2}
BuildRequires:	pam-devel
BuildRequires:	pango-devel
BuildRequires:	pciutils-devel
BuildRequires:	perl-JSON
BuildRequires:	perl-modules
BuildRequires:	pkgconfig
%{?with_system_protobuf:BuildRequires:	protobuf-devel}
%{?with_pulseaudio:BuildRequires:	pulseaudio-devel}
BuildRequires:	python
#BuildRequires:	python-gyp >= 1-%{gyp_rev}
BuildRequires:	python-jinja2 >= 2.7
BuildRequires:	python-modules
BuildRequires:	python-ply >= 3.4
%{?with_system_re2:BuildRequires:	re2-devel >= 20130115-2}
BuildRequires:	rpm >= 4.4.9-56
BuildRequires:	rpmbuild(macros) >= 1.453
%{?with_system_snappy:BuildRequires:	snappy-devel}
BuildRequires:	speech-dispatcher-devel >= 0.8
%{?with_system_speex:BuildRequires:	speex-devel >= 1:1.2-rc1}
%{?with_system_sqlite:BuildRequires:	sqlite3-devel >= 3.7}
%{?with_system_libsrtp:BuildRequires:	srtp-devel >= 1.4.4}
BuildRequires:	tar >= 1:1.22
BuildRequires:	udev-devel
BuildRequires:	usbutils
BuildRequires:	util-linux
%{?with_system_v8:BuildRequires:	v8-devel >= 3.7}
BuildRequires:	which
BuildRequires:	xorg-lib-libXScrnSaver-devel
BuildRequires:	xorg-lib-libXtst-devel
BuildRequires:	xz
%{?with_system_yasm:BuildRequires:	yasm}
%{?with_system_zlib:BuildRequires:	zlib-devel}
Requires:	browser-plugins >= 2.0
Requires:	desktop-file-utils
%{?with_system_flac:Requires:	flac >= 1.2.1-7}
# crashes if no fontconfig font present
Requires:	fonts-Type1-urw
Requires:	hicolor-icon-theme
Requires:	libevent >= 2.0.21
%{?with_libjpegturbo:Requires:	libjpeg-turbo >= 1.2.0}
%{?with_system_libvpx:Requires:	libvpx >= 1.3.0}
Requires:	lsb-release
%{?with_system_re2:Requires:	re2 >= 20130115-2}
Requires:	shared-mime-info
%{?with_system_sqlite:Requires:	sqlite3(icu)}
Requires:	xdg-utils >= 1.0.2-4
Requires:	xorg-lib-libX11 >= 1.4.99.1
Provides:	wwwbrowser
Obsoletes:	chromium-browser-bookmark_manager < 5.0.388.0
Obsoletes:	chromium-browser-inspector < 15.0.863.0
ExclusiveArch:	%{ix86} %{x8664} arm
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

# Set up Google API keys, see http://www.chromium.org/developers/how-tos/api-keys
# Note: these are for PLD Linux use ONLY.
# For your own distribution, please get your own set of keys.
%define		google_api_key AIzaSyD1tTgDbP-N6BGXKZ7VqSos_IU1QflGbyg
%define		google_default_client_id 724288223830.apps.googleusercontent.com
%define		google_default_client_secret rHmKOPygcI6G-clFHb-RfuHb

%define		find_lang	sh find-lang.sh %{buildroot}

# Usage: gyp_with BCOND_NAME [OPTION_NAME]
%define		gyp_with() %{expand:%%{?with_%{1}:-D%{?2:use_%{2}}%{!?2:use_%{1}}=1}%%{!?with_%{1}:-D%{?2:use_%{2}}%{!?2:use_%{1}}=0}}

%ifarch %{ix86}
%define		target_arch ia32
%endif
%ifarch %{x8664}
%define		target_arch x64
%endif

%define		buildtype	%{?debug:Debug}%{!?debug:Release}
%define		builddir	out/%{buildtype}

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
%if "%{_rpmversion}" >= "5"
BuildArch:	noarch
%endif

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
%setup -qc
%if "%{?patchver}" != ""
cd chromium*-%{branch}.%{basever}
%patch0 -p1
cd ..
%endif
mv chromium*-%{branch}.%{basever}/* .

# Google's versioning is interesting. They never reset "BUILD", which is how we jumped
# from 3.0.201.0 to 4.0.202.0 as they moved to a new major branch
. ./chrome/VERSION
chrome=$MAJOR.$MINOR.$BUILD.$PATCH
test "$chrome" = %{version}

gyp_rev=$(grep googlecode_url.*gyp DEPS | cut -d'"' -f6 | cut -d@ -f2)
test "$gyp_rev" = %{gyp_rev} || :

# add chromium and pld to useragent
%define pld_version %(echo %{pld_release} | sed -e 'y/[at]/[AT]/')
sed -e 's/@BUILD_DIST@/PLD %{pld_version}/g' \
	-e 's/@BUILD_DIST_NAME@/PLD/g' \
	-e 's/@BUILD_DIST_VERSION@/%{pld_version}/g' \
	< %{PATCH8} | %{__patch} -p1

%{__sed} -e 's,@localedir@,%{_datadir}/%{name},' %{SOURCE5} > find-lang.sh
ln -s %{SOURCE7} .

#%patch2 -p1 NOT COMPILING
%patch4 -p3
%patch7 -p1
%patch15 -p2
%{!?with_libjpegturbo:%patch11 -p0}
%patch16 -p1
%patch28 -p1
%patch25 -p1
%{?with_nacl:%patch18 -p1}
%patch24 -p1
%patch26 -p2
#%patch30 -p1
#%patch31 -p0
%patch32 -p1
%patch35 -p1

%{?with_dev:exit 0}

sh -x clean-source.sh \
	%{!?with_nacl:nacl=0} \
	%{!?with_system_libvpx:libvpx=0} \
	%{!?with_system_libxnvctrl:libXNVCtrl=0} \
	%{!?with_system_mesa:mesa=0} \
	%{!?with_system_protobuf:protobuf=0} \
	%{!?with_system_re2:re2=0} \
	%{!?with_system_snappy:snappy=0} \
	%{!?with_system_sqlite:sqlite=0} \
	%{!?with_system_v8:v8=0} \
	%{!?with_system_libwebp:libwebp=0} \
	%{!?with_system_zlib:zlib=0} \
	%{!?with_system_ffmpeg:ffmpeg=0} \
	%{nil}

%build
%if %{with nacl}
rm -rf native_client/toolchain/linux_x86_newlib
if [ ! -d native_client/toolchain/linux_x86_newlib ]; then
# Make symlinks for NaCL
install -d native_client/toolchain/linux_x86_newlib/x86_64-nacl/{bin,nacl}

cd native_client/toolchain/linux_x86_newlib
ln -s x86_64-nacl/bin bin
cd x86_64-nacl/bin
__cc='%{__cc}'
if [ "${__cc#ccache}" != "$__cc" ]; then
	echo 'exec ccache %{_bindir}/x86_64-nacl-gcc "$@"' > gcc
	echo 'exec ccache %{_bindir}/x86_64-nacl-g++ "$@"' > g++
	%{__sed} -i -e '1i#!/bin/sh' gcc g++
	chmod +x gcc g++
else
	ln -s %{_bindir}/x86_64-nacl-gcc gcc
	ln -s %{_bindir}/x86_64-nacl-g++ g++
fi
ln -s gcc x86_64-nacl-gcc
ln -s g++ x86_64-nacl-g++
ln -s %{_bindir}/x86_64-nacl-ar .
ln -s %{_bindir}/x86_64-nacl-ar ar
ln -s %{_bindir}/x86_64-nacl-as as
ln -s %{_bindir}/x86_64-nacl-ranlib .
ln -s %{_bindir}/x86_64-nacl-ranlib ranlib
ln -s %{_bindir}/x86_64-nacl-strip .
ln -s %{_bindir}/x86_64-nacl-strip strip
ln -s %{_bindir}/x86_64-nacl-objcopy .
ln -s %{_prefix}/x86_64-nacl/lib ../lib
ln -s %{_prefix}/x86_64-nacl/lib32 ../lib32
ln -s %{_prefix}/x86_64-nacl/include ../nacl/include
cd ../../../../..
fi
%endif

%if %{without system_ffmpeg}
if [ ! -d third_party/ffmpeg/build.%{target_arch}.linux ]; then
	# Re-configure bundled ffmpeg
	cd third_party/ffmpeg
	chromium/scripts/build_ffmpeg.sh linux %{target_arch} "$PWD" config-only
	chromium/scripts/copy_config.sh
	cd -
fi
%endif

flags="
	-Dtarget_arch=%{target_arch} \
	-Dpython_arch=%{target_arch} \
	-Dsystem_libdir=%{_lib} \
	-Dpython_ver=%{py_ver} \
%if "%{cc_version}" >= "4.4.0" && "%{cc_version}" < "4.5.0"
	-Dno_strict_aliasing=1 -Dgcc_version=44 \
%endif
	%{!?debug:-Dwerror= -Ddisable_fatal_linker_warnings=} \
	%{!?debuginfo:-Dfastbuild=1 -Dremove_webcore_debug_symbols=1} \
	%{?with_shared_libs:-Dlibrary=shared_library} \
	%{!?with_system_ffmpeg:-Dbuild_ffmpegsumo=1} -Dproprietary_codecs=1 \
	-Dinclude_tests__=0 \
%if %{with nacl}
	-Dnaclsdk_mode=custom:/usr/x86_64-nacl \
	-Ddisable_glibc_untar=1 \
	-Ddisable_newlib_untar=1 \
	-Ddisable_glibc=1 \
	-Ddisable_pnacl=1 \
	-Dbuild_pnacl_newlib=0 \
%else
	-Ddisable_pnacl_untar=1 \
	-Ddisable_nacl=1 \
%endif
	%{!?with_sse2:-Ddisable_sse2=1} \
	%{?with_selinux:-Dselinux=1} \
	-Dusb_ids_path=$(pkg-config --variable usbids usbutils) \
	-Dlinux_link_libpci=1 \
	-Dlinux_link_libspeechd=1 -Dlibspeechd_h_prefix=speech-dispatcher/ \
	-Duse_allocator=%{!?with_tcmalloc:none}%{?with_tcmalloc:tcmalloc} \
	%{?with_gps:-Dlinux_use_libgps=1 -Dlinux_link_libgps=1} \
	-Dlinux_use_bundled_binutils=0 \
	-Dlinux_use_bundled_gold=0 \
	-Dlinux_use_gold_flags=0 \
	-Dlogging_like_official_build=1 \
	-Dgoogle_api_key=%{google_api_key} \
	-Dgoogle_default_client_id=%{google_default_client_id} \
	-Dgoogle_default_client_secret=%{google_default_client_secret} \
	%{gyp_with cups} \
	%{gyp_with gconf} -Dlinux_link_gsettings=0 \
	%{gyp_with kerberos} -Dlinux_link_kerberos=1 \
	%{gyp_with keyring gnome_keyring} -Dlinux_link_gnome_keyring=0 \
	%{gyp_with pulseaudio} \
	%{gyp_with system_ffmpeg} -Dmedia_use_ffmpeg=1 \
	%{gyp_with system_flac} \
	%{gyp_with system_harfbuzz} \
	%{gyp_with system_jsoncpp} \
	%{gyp_with system_libexif} \
	%{gyp_with system_libmtp} \
	%{gyp_with system_libsrtp} \
	%{gyp_with system_libusb} \
	%{gyp_with system_libvpx} -Dmedia_use_libvpx=1 \
	%{gyp_with system_libwebp} \
	%{gyp_with system_libxnvctrl} \
	%{gyp_with system_mesa} \
	%{gyp_with system_minizip} \
	%{gyp_with system_opus} \
	%{gyp_with system_protobuf} \
	%{gyp_with system_re2} \
	%{gyp_with system_snappy} \
	%{gyp_with system_speex} \
	%{gyp_with system_sqlite} %{?with_system_sqlite:-Denable_sql_database=0} \
	%{gyp_with system_v8} \
	%{gyp_with system_yasm} \
	%{gyp_with system_zlib} \
	-Duse_system_bzip2=1 \
	-Duse_system_expat=1 \
	-Duse_system_icu=1 -Dicu_use_data_file_flag=0 \
	-Duse_system_libevent=1 \
	-Duse_system_libjpeg=1 \
	-Duse_system_libpng=1 \
	-Duse_system_libxml=1 \
	-Duse_system_libxslt=1 \
	-Duse_system_nspr=1 \
	-Duse_system_xdg_utils=1 \
"

build/linux/unbundle/replace_gyp_files.py $flags

%if %{with ninja}
chkfile=%{builddir}/build.ninja
%else
chkfile=Makefile
%endif
test %{_specdir}/%{name}.spec -nt $chkfile && %{__rm} -f $chkfile
test -e $chkfile || \
	CC="%{__cc}" \
	CXX="%{__cxx}" \
	LDFLAGS="%{rpmldflags} -fuse-ld=gold" \
	CFLAGS="%{rpmcflags} %{rpmcppflags}" \
	CXXFLAGS="%{rpmcxxflags} %{rpmcppflags}" \
	CC_host="%{__cc}" \
	CXX_host="%{__cxx}" \
	LD_host="%{__cxx}" \
%{__python} build/gyp_chromium \
	--format=%{?with_ninja:ninja}%{!?with_ninja:make} \
	--depth=. \
	build/all.gyp \
	$flags

%if %{with ninja}
ninja %{?_smp_mflags} %{?with_verbose:-v} -C %{builddir} \
%else
# need {CC/CXX/LDFLAGS}.host overrides for v8 build
%{__make} -r \
	BUILDTYPE=%{buildtype} \
	%{?with_verbose:V=1} \
	CC.host="%{__cc}" \
	CXX.host="%{__cxx}" \
	LDFLAGS.host="%{rpmldflags} -fuse-ld=gold" \
%endif
	chrome %{?with_sandboxing:chrome_sandbox} \
	%{nil}

cd %{builddir}
MANWIDTH=80 man ./chrome.1 > man.out
%{__sed} -e '1,/OPTIONS/d; /ENVIRONMENT/,$d' man.out > options.txt

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_libdir}/%{name}/plugins \
	$RPM_BUILD_ROOT%{_datadir}/%{name}/{locales,resources} \
	$RPM_BUILD_ROOT{%{_bindir},%{_mandir}/man1,%{_desktopdir}} \
	$RPM_BUILD_ROOT%{_sysconfdir}/%{name}/{native-messaging-hosts,policies/managed}

cd %{builddir}
cp -p %{SOURCE1} $RPM_BUILD_ROOT%{_sysconfdir}/%{name}/default
install -p %{SOURCE2} $RPM_BUILD_ROOT%{_bindir}/%{name}
%{__sed} -i -e '
	s,@libdir@,%{_libdir}/%{name},

	/@OPTIONS@/ {
		r options.txt
		d
	}
' $RPM_BUILD_ROOT%{_bindir}/%{name}
cp -a locales resources $RPM_BUILD_ROOT%{_datadir}/%{name}
cp -p *.pak $RPM_BUILD_ROOT%{_libdir}/%{name}
ln -s %{_datadir}/%{name}/locales $RPM_BUILD_ROOT%{_libdir}/%{name}/locales
ln -s %{_datadir}/%{name}/resources $RPM_BUILD_ROOT%{_libdir}/%{name}/resources
cp -p chrome.1 $RPM_BUILD_ROOT%{_mandir}/man1/%{name}.1
install -p chrome $RPM_BUILD_ROOT%{_libdir}/%{name}/%{name}
install -p chrome_sandbox $RPM_BUILD_ROOT%{_libdir}/%{name}/chrome-sandbox
%if %{without system_ffmpeg}
install -p libffmpegsumo.so $RPM_BUILD_ROOT%{_libdir}/%{name}
%endif
cp -p %{SOURCE3} $RPM_BUILD_ROOT%{_desktopdir}
cp -p %{SOURCE9} $RPM_BUILD_ROOT%{_sysconfdir}/%{name}/master_preferences

%{__rm} -r $RPM_BUILD_ROOT%{_datadir}/%{name}/resources/extension/demo

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

for icon in chrome/app/theme/chromium/product_logo_[0-9]*.png; do
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

%pretrans
for d in locales resources; do
	if [ -d %{_libdir}/%{name}/$d ] && [ ! -L %{_libdir}/%{name}/$d ]; then
		install -d %{_datadir}/%{name}
		mv %{_libdir}/%{name}/$d %{_datadir}/%{name}/$d
	fi
done
exit 0

%post
%update_icon_cache hicolor
%update_desktop_database
%update_browser_plugins

%postun
if [ "$1" = 0 ]; then
	%update_icon_cache hicolor
	%update_browser_plugins
fi

%files
%defattr(644,root,root,755)
%doc AUTHORS LICENSE
%{_browserpluginsconfdir}/browsers.d/%{name}.*
%config(noreplace) %verify(not md5 mtime size) %{_browserpluginsconfdir}/blacklist.d/%{name}.*.blacklist
%dir %{_sysconfdir}/%{name}
%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/%{name}/default
%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/%{name}/master_preferences
%dir %{_sysconfdir}/%{name}/native-messaging-hosts
%dir %{_sysconfdir}/%{name}/policies
%dir %{_sysconfdir}/%{name}/policies/managed
%attr(755,root,root) %{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*
%{_desktopdir}/*.desktop
%{_iconsdir}/hicolor/*/apps/%{name}.png
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/chrome*.pak
%{_libdir}/%{name}/content_resources.pak
%{_libdir}/%{name}/keyboard_resources.pak
%{_libdir}/%{name}/resources.pak
%{_libdir}/%{name}/locales
%{_libdir}/%{name}/resources

%dir %{_datadir}/%{name}
%dir %{_datadir}/%{name}/locales
%{_datadir}/%{name}/locales/en-US.pak
%dir %{_datadir}/%{name}/resources
%{_datadir}/%{name}/resources/inspector

%dir %{_libdir}/%{name}/plugins
%attr(755,root,root) %{_libdir}/%{name}/%{name}
# These unique permissions are intentional and necessary for the sandboxing
%attr(4555,root,root) %{_libdir}/%{name}/chrome-sandbox

# ffmpeg libs
%if %{without system_ffmpeg}
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
