#
# Conditional build:
%bcond_with	selinux		# with SELinux (need policy first)

# TODO
# - spec vs name
# - merge google-chromium.spec vs chromium-browser.spec -- one must go
# spec from  http://spot.fedorapeople.org/chromium/

%define		svndate 20090916
%define		svnver  svn26424
Summary:	A WebKit powered web browser
Name:		chromium-browser
Version:	4.0.212.0
Release:	0.1.%{svndate}%{svnver}%{?dist}
License:	BSD, LGPL v2+ (ffmpeg)
Group:		Applications/Networking
Patch0:		system-libs.patch
Patch1:		system-libs-gyp.patch
Patch2:		gyp-system-minizip.patch
Patch3:		noffmpeg.patch
Patch5:		options-support.patch
Patch6:		64bit-plugin-path.patch
Patch7:		gyp-system-icu.patch
Patch8:		icu-code-changes.patch
Patch9:		no-sqlite-debug.patch
Patch10:	debug_util_posix-fix.patch
Source0:	chromium-%{svndate}%{svnver}.tar.bz2
# Source0-md5:	20663b974249b35d7ab655ce21b8f868
# Custom build tools for chromium, hammer is a fancy front-end for scons
Source1:	http://src.chromium.org/svn/trunk/tools/depot_tools.tar.gz
# Source1-md5:	1f821101d5a6f26345dc22ae5e0cbe1e
Source2:	%{name}.sh
Source3:	%{name}.desktop
# We don't actually use this in the build, but it is included so you can make the tarball.
Source4:	chromium-daily-tarball.sh
BuildRequires:	GConf2-devel
BuildRequires:	alsa-lib-devel
BuildRequires:	atk-devel
BuildRequires:	bison
BuildRequires:	bzip2-devel
BuildRequires:	dbus-devel
BuildRequires:	desktop-file-utils
BuildRequires:	flex
BuildRequires:	fontconfig-devel
BuildRequires:	gperf
BuildRequires:	gtk+2-devel
BuildRequires:	libevent-devel
BuildRequires:	libicu-devel
BuildRequires:	libjpeg-devel
BuildRequires:	libpng-devel
%{?with_selinux:BuildRequires:	libselinux-devel}
BuildRequires:	libstdc++-devel
BuildRequires:	libxslt-devel
BuildRequires:	minizip-devel
BuildRequires:	nspr-devel
BuildRequires:	nss-devel
BuildRequires:	scons
BuildRequires:	v8-devel
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)
# Chromium bits don't compile on x86_64.
ExclusiveArch:	%{x8664} %{ix86} arm

%description
Chromium is an open-source web browser, powered by WebKit.

%prep
%setup -q -n chromium-%{svndate}%{svnver} -a 1

# Google's versioning is interesting. They never reset "BUILD", which is how we jumped
# from 3.0.201.0 to 4.0.202.0 as they moved to a new major branch
. ./src/chrome/VERSION
ver=$MAJOR.$MINOR.$BUILD.$PATCH
if [ "$ver" != %{version} ]; then
	exit 1
fi

%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch5 -p1
%patch6 -p1
%patch7 -p1
%patch8 -p1
%patch9 -p1
%patch10 -p1

# Scrape out incorrect optflags and hack in the correct ones
find -name '*\.scons' | xargs %{__sed} -i -e "
	s|'-march=pentium4',||g
	s|'-msse2',||g
	s|'-mfpmath=sse',||g
	s|'-m32',||g
	s|'-O0',|'%{rpmcxxflags}'.split(' ')|g
"

%build
cd src/build

# Regenerate the scons files
# Also, set the sandbox paths correctly.
./gyp_chromium all.gyp \
	-D linux_sandbox_path=%{_libdir}/%{name}/chrome-sandbox \
	-D linux_sandbox_chrome_path=%{_libdir}/%{name}/chromium-browser \
%ifarch x86_64
	-Dtarget_arch=x64 \
%endif
	-Duse_system_libpng=1 \
	-Duse_system_bzip2=1 \
	-Duse_system_libjpeg=1 \
	-Duse_system_zlib=1 \
%if %{with selinux}
	-Dselinux=1 \
%endif
	-Djavascript_engine=v8

# If we're building sandbox without SELINUX, add "chrome_sandbox" here.
%if %{with selinux}
../../depot_tools/hammer --mode=Release chrome
%else
../../depot_tools/hammer --mode=Release chrome chrome_sandbox
%endif

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_bindir},%{_libdir}/%{name},%{_pixmapsdir},%{_desktopdir}}

cd src/sconsbuild/Release
install -p %{SOURCE2} $RPM_BUILD_ROOT%{_bindir}/chromium-browser
cp -a chrome.pak locales resources themes $RPM_BUILD_ROOT%{_libdir}/%{name}
cp -a chrome $RPM_BUILD_ROOT%{_libdir}/%{name}/chromium-browser
cp -a chrome_sandbox $RPM_BUILD_ROOT%{_libdir}/%{name}/chrome-sandbox
cd -

cp -a src/chrome/app/theme/chromium/product_logo_48.png $RPM_BUILD_ROOT%{_pixmapsdir}/chromium-browser.png

desktop-file-install --dir $RPM_BUILD_ROOT%{_desktopdir} %{SOURCE3}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{_bindir}/chromium-browser
%{_pixmapsdir}/chromium-browser.png
%{_desktopdir}/*.desktop
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/chrome.pak
%{_libdir}/%{name}/chromium-browser
%{_libdir}/%{name}/locales
%{_libdir}/%{name}/resources
%{_libdir}/%{name}/themes
# These unique permissions are intentional and necessary for the sandboxing
%attr(4555,root,root) %{_libdir}/%{name}/chrome-sandbox
