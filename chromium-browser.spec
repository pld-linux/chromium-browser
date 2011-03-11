#
# Conditional build:
%bcond_with	verbose		# verbose build (V=1)
%bcond_with	selinux		# with SELinux (need policy first)
%bcond_with	shared_libs	# with shared libs
%bcond_with	sse2		# use SSE2 instructions
%bcond_with	system_sqlite	# with system sqlite
%bcond_with	system_v8	# with system v8
%bcond_without	ffmpegsumo	# build with ffmpegsumo
%bcond_without	sandboxing	# with sandboxing
%bcond_without	system_zlib	# with system zlib
%bcond_without	keyring 	# with keyring support (gnome-keyring dlopened, kwalletd via dbus)
%bcond_without	debuginfo	# disable debuginfo creation (it is huge)

# TODO
# - check system sqlite linking problems

# NOTES:
# - mute BEEP mixer if you do not want to hear horrible system bell when
#   pressing home/end in url bar or more ^F search results on page.
# - build i686: -bp: ~570MB; bc: ~928MB; -bb: ~1.0GB
# - build x86_64: -bp: ~570MB; bc: ~990MB; -bb: ~1.0GB
# - http://code.google.com/p/chromium/wiki/LinuxBuildInstructionsPrerequisites
# - to look for new tarball, use update-source.sh script

# NOTE TO USERS:
# To use chromium nightly builds for pld-th save to /etc/poldek/repos.d (as chromium-nightly.conf):
# http://carme.pld-linux.org/~glen/chromium-browser/th/i686/chromium-nightly.conf
# or:
# http://carme.pld-linux.org/~glen/chromium-browser/th/x86_64/chromium-nightly.conf

%define		svndate	20110311
%define		svnver	77774
%define		rel	1

Summary:	A WebKit powered web browser
Name:		chromium-browser
Version:	12.0.700.0
Release:	0.%{svnver}.%{rel}
License:	BSD, LGPL v2+ (ffmpeg)
Group:		X11/Applications/Networking
Source0:	http://ppa.launchpad.net/chromium-daily/ppa/ubuntu/pool/main/c/chromium-browser/%{name}_%{version}~svn%{svndate}r%{svnver}.orig.tar.gz
# Source0-md5:	dc38e6d5e52919f4e8cfbeb4e204d710
Source2:	%{name}.sh
Source3:	%{name}.desktop
Source4:	find-lang.sh
Source5:	update-source.sh
Patch0:		system-libs.patch
Patch1:		plugin-searchdirs.patch
Patch2:		gyp-system-minizip.patch
Patch3:		disable_dlog_and_dcheck_in_release_builds.patch
# http://aur.archlinux.org/packages/chromium-browser-svn/chromium-browser-svn/search-workaround.patch
Patch4:		search-workaround.patch
Patch5:		options-support.patch
Patch6:		get-webkit_revision.patch
Patch7:		dlopen_sonamed_gl.patch
Patch8:		chromium_useragent.patch.in
URL:		http://code.google.com/chromium/
BuildRequires:	GConf2-devel
BuildRequires:	OpenGL-GLU-devel
BuildRequires:	alsa-lib-devel
BuildRequires:	atk-devel
BuildRequires:	bison
BuildRequires:	bzip2-devel
BuildRequires:	cups-devel
BuildRequires:	dbus-glib-devel
BuildRequires:	flex
BuildRequires:	fontconfig-devel
BuildRequires:	glib2-devel
BuildRequires:	gperf
BuildRequires:	gtk+2-devel
BuildRequires:	libevent-devel
%{?with_keyring:BuildRequires:	libgnome-keyring-devel}
BuildRequires:	libjpeg-devel
BuildRequires:	libpng-devel
%{?with_selinux:BuildRequires:	libselinux-devel}
BuildRequires:	libstdc++-devel
BuildRequires:	libvpx-devel >= 0.9.5-2
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
BuildRequires:	python
BuildRequires:	rpm >= 4.4.9-56
# grep googlecode_url.*gyp src/DEPS |cut -d'"' -f6 | cut -d@ -f2
BuildRequires:	python-gyp >= 1-840
BuildRequires:	python-modules
BuildRequires:	rpmbuild(macros) >= 1.453
BuildRequires:	sqlite3-devel >= 3.6.1
BuildRequires:	util-linux
%{?with_system_v8:BuildRequires:	v8-devel}
BuildRequires:	which
BuildRequires:	xorg-lib-libXScrnSaver-devel
BuildRequires:	xorg-lib-libXt-devel
BuildRequires:	xorg-lib-libXtst-devel
BuildRequires:	yasm
%{?with_system_zlib:BuildRequires:	zlib-devel}
Requires:	browser-plugins >= 2.0
Requires:	libvpx >= 0.9.5-2
Requires:	xdg-utils >= 1.0.2-4
Provides:	wwwbrowser
Obsoletes:	chromium-browser-bookmark_manager
ExclusiveArch:	%{ix86} %{x8664} arm
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		find_lang 	sh find-lang.sh %{buildroot}

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

%package inspector
Summary:	Page inspector for the chromium-browser
Group:		Development/Tools
Requires:	%{name} = %{version}-%{release}

%description inspector
Chromium is an open-source browser project that aims to build a safer,
faster, and more stable way for all Internet users to experience the
web.

This package contains 'inspector', allowing web developpers to inspect
any element of a web page at runtime (html, javascript, css, ..)

%package l10n
Summary:	chromium-browser language packages
Group:		I18n
Requires:	%{name} = %{version}-%{release}

%description l10n
Chromium is an open-source browser project that aims to build a safer,
faster, and more stable way for all Internet users to experience the
web.

This package contains language packages for 50 languages:

ar, bg, bn, ca, cs, da, de, el, en-GB, es-419, es, et, fi, fil, fr,
gu, he, hi, hr, hu, id, it, ja, kn, ko, lt, lv, ml, mr, nb, nl, or,
pl, pt-BR, pt-PT, ro, ru, sk, sl, sr, sv, ta, te, th, tr, uk, vi,
zh-CN, zh-TW

%prep
%setup -q -n %{name}-%{version}~svn%{svndate}r%{svnver}
lzma -dc %{name}-%{version}~svn%{svndate}r%{svnver}-source.tar.lzma | tar x
rm -f %{name}-%{version}~svn%{svndate}r%{svnver}-source.tar.lzma

# Google's versioning is interesting. They never reset "BUILD", which is how we jumped
# from 3.0.201.0 to 4.0.202.0 as they moved to a new major branch
. ./src/chrome/VERSION
ver=$MAJOR.$MINOR.$BUILD.$PATCH
if [ "$ver" != %{version} ]; then
	exit 1
fi

# Populate the LASTCHANGE file template as we no longer have the VCS files at this point
echo "%{svnver}" > src/build/LASTCHANGE.in

# add chromium and pld to useragent
%define pld_version %(echo %{pld_release} | sed -e 'y/[at]/[AT]/')
sed -e 's/@BUILD_DIST@/PLD %{pld_version}/g' \
    -e 's/@BUILD_DIST_NAME@/PLD/g' \
    -e 's/@BUILD_DIST_VERSION@/%{pld_version}/g' \
    < %{PATCH8} | %{__patch} -p1

%{__sed} -e 's,@localedir@,%{_libdir}/%{name},' %{SOURCE4} > find-lang.sh

%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p1
%patch6 -p1
%patch7 -p1

# drop bundled libs, from gentoo
remove_bundled_lib() {
	echo "Removing bundled library $1 ..."
	local out
	out=$(find $1 -mindepth 1 ! -iname '*.gyp' -print -delete)
	if [ -z "$out" ]; then
		echo >&2 "No files matched when removing bundled library $1"
		exit 1
	fi
}

cd src
remove_bundled_lib "third_party/bzip2"
remove_bundled_lib "third_party/libevent"
remove_bundled_lib "third_party/libjpeg"
remove_bundled_lib "third_party/libpng"
# third_party/libvpx/libvpx.h should be kept
#remove_bundled_lib "third_party/libvpx"
remove_bundled_lib "third_party/libxml"
remove_bundled_lib "third_party/libxslt"
remove_bundled_lib "third_party/zlib"

%build
cd src
%{__python} build/gyp_chromium --format=make build/all.gyp \
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
	%{!?debuginfo:-Dfastbuild=1} \
	%{?with_shared_libs:-Dlibrary=shared_library} \
	-Djavascript_engine=%{?with_system_v8:system-v8}%{!?with_system_v8:v8} \
	-Dbuild_ffmpegsumo=%{?with_ffmpegsumo:1}%{!?with_ffmpegsumo:0} \
	-Duse_system_bzip2=1 \
	-Duse_system_libevent=1 \
	-Duse_system_libjpeg=1 \
	-Duse_system_libpng=1 \
	-Duse_system_libxml=1 \
	-Duse_system_libxslt=1 \
	-Duse_system_sqlite=%{?with_system_sqlite:1}%{!?with_system_sqlite:0} \
	-Duse_system_vpx=1 \
	-Duse_system_xdg_utils=1 \
	-Duse_system_yasm=1 \
	-Duse_system_zlib=%{?with_system_zlib:1}%{!?with_system_zlib:0} \
	-Dffmpeg_branding=Chrome \
	-Dproprietary_codecs=1 \
%if %{with keyring}
	-Duse_gnome_keyring=1 -Dlinux_link_gnome_keyring=0 \
%else
	-Duse_gnome_keyring=0 \
%endif
	%{!?with_sse2:-Ddisable_sse2=1} \
%if %{with selinux}
	-Dselinux=1 \
%endif

%{__make} chrome %{?with_sandboxing:chrome_sandbox} \
	BUILDTYPE=%{!?debug:Release}%{?debug:Debug} \
	%{?with_verbose:V=1} \
	CC="%{__cc}" \
	CXX="%{__cxx}" \
	CC.host="%{__cc}" \
	CXX.host="%{__cxx}" \
	CFLAGS="%{rpmcflags} %{rpmcppflags}" \
	CXXFLAGS="%{rpmcxxflags} %{rpmcppflags}"

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_bindir},%{_libdir}/%{name}/{themes,locales,plugins,extensions,resources},%{_mandir}/man1,%{_pixmapsdir},%{_desktopdir}}

cd src/out/%{!?debug:Release}%{?debug:Debug}
install -p %{SOURCE2} $RPM_BUILD_ROOT%{_bindir}/%{name}
%{__sed} -i -e 's,@libdir@,%{_libdir}/%{name},' $RPM_BUILD_ROOT%{_bindir}/%{name}
cp -a *.pak locales resources $RPM_BUILD_ROOT%{_libdir}/%{name}
cp -p chrome.1 $RPM_BUILD_ROOT%{_mandir}/man1/%{name}.1
install -p chrome $RPM_BUILD_ROOT%{_libdir}/%{name}/%{name}
install -p chrome_sandbox $RPM_BUILD_ROOT%{_libdir}/%{name}/chromium-sandbox
%if %{with ffmpegsumo}
install -p libffmpegsumo.so $RPM_BUILD_ROOT%{_libdir}/%{name}
%endif
cp -a %{SOURCE3} $RPM_BUILD_ROOT%{_desktopdir}
cd -

cp -p src/chrome/app/theme/chromium/product_logo_48.png $RPM_BUILD_ROOT%{_pixmapsdir}/%{name}.png

%browser_plugins_add_browser %{name} -p %{_libdir}/%{name}/plugins -b <<'EOF'
# http://code.google.com/p/chromium/issues/detail?id=24507
gecko-mediaplayer*.so
EOF

# find locales
%find_lang %{name}.lang
%{__sed} -i -e '/en-US.pak/d' %{name}.lang

%clean
rm -rf $RPM_BUILD_ROOT

%post
%update_browser_plugins

%postun
if [ "$1" = 0 ]; then
	%update_browser_plugins
fi

%files -f %{name}.lang
%defattr(644,root,root,755)
%{_browserpluginsconfdir}/browsers.d/%{name}.*
%config(noreplace) %verify(not md5 mtime size) %{_browserpluginsconfdir}/blacklist.d/%{name}.*.blacklist
%attr(755,root,root) %{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*
%{_pixmapsdir}/%{name}.png
%{_desktopdir}/*.desktop
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/chrome.pak
%{_libdir}/%{name}/resources.pak
%dir %{_libdir}/%{name}/locales
%{_libdir}/%{name}/locales/en-US.pak
%dir %{_libdir}/%{name}/resources
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

%files inspector
%defattr(644,root,root,755)
%{_libdir}/%{name}/resources/inspector

%files l10n -f %{name}.lang
%defattr(644,root,root,755)
