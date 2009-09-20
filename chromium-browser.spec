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
# Source1-md5:	40811b18e2cbdc900272618486bf37e1
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
BuildRequires:	libjpeg-devel
BuildRequires:	libpng-devel
BuildRequires:	libstdc++-devel
BuildRequires:	libxslt-devel
BuildRequires:	minizip-devel
BuildRequires:	nspr-devel
BuildRequires:	nss-devel
BuildRequires:	scons
BuildRequires:	v8-devel
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)
# Chromium bits don't compile on x86_64.
ExclusiveArch:	%{ix86} arm

%description
Chromium is an open-source web browser, powered by WebKit.

%prep
%setup -q -n %{name}-%{svndate}%{svnver} -a 1

# see src/chrome/VERSION
# Google's versioning is interesting. They never reset "BUILD", which is how we jumped
# from 3.0.201.0 to 4.0.202.0 as they moved to a new major branch
ver=$(cat src/chrome/VERSION)
if [ "$ver" != %{version} ]; then
	exit 1
fi

cp %{SOURCE4} .

# Somehow, path noise from the tarball creation got embedded.
# Thanks gclient. :P
# FIXME: Figure out how to avoid this
for i in `find . |grep "\.scons"`; do
	sed -i "s|/home/spot/sandbox/chromium-%{svndate}/|%{_builddir}/chromium-%{svndate}%{svnver}/|g" $i
done

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
PARSED_OPT_FLAGS=`echo \'$RPM_OPT_FLAGS \' | sed "s/ /',/g" | sed "s/',/', '/g"`
for i in `find . |grep "\.scons"`; do
	sed -i "s|'-march=pentium4',||g" $i
	sed -i "s|'-msse2',||g" $i
	sed -i "s|'-mfpmath=sse',||g" $i
	sed -i "s|'-O0',||g" $i
	sed -i "s|'-m32',|$PARSED_OPT_FLAGS|g" $i
done

# Change the location for the sandbox helper binary
sed -i 's|/opt/google/chrome/chrome-sandbox|%{_libdir}/chromium-browser/chrome-sandbox|g' src/chrome/browser/zygote_host_linux.cc

# Tell the sandbox code where to find chromium-browser
sed -i 's|/opt/google/chrome/chrome|%{_libdir}/chromium-browser/chromium-browser|g' src/sandbox/linux/suid/sandbox.cc

%build
cd src/build/
../../depot_tools/hammer --mode=Release chrome chrome_sandbox

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_bindir}
cp -a %{SOURCE2} $RPM_BUILD_ROOT%{_bindir}/chromium-browser
install -d $RPM_BUILD_ROOT%{_libdir}/chromium-browser/
pushd src/sconsbuild/Release
cp -a chrome.pak locales resources themes $RPM_BUILD_ROOT%{_libdir}/chromium-browser/
cp -a chrome $RPM_BUILD_ROOT%{_libdir}/chromium-browser/chromium-browser
cp -a chrome_sandbox $RPM_BUILD_ROOT%{_libdir}/chromium-browser/chrome-sandbox
popd

install -d $RPM_BUILD_ROOT%{_pixmapsdir}/
cp -a src/chrome/app/theme/chromium/product_logo_48.png $RPM_BUILD_ROOT%{_pixmapsdir}/chromium-browser.png

install -d $RPM_BUILD_ROOT%{_desktopdir}/
desktop-file-install --dir $RPM_BUILD_ROOT%{_desktopdir} %{SOURCE3}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%doc chromium-daily-tarball.sh
%attr(755,root,root) %{_bindir}/chromium-browser
%dir %{_libdir}/chromium-browser/
%{_libdir}/chromium-browser/chrome.pak
# These unique permissions are intentional and necessary for the sandboxing
%{_libdir}/chromium-browser/chromium-browser
%attr(4555, root, root) %{_libdir}/chromium-browser/chrome-sandbox
%{_libdir}/chromium-browser/locales/
%{_libdir}/chromium-browser/resources/
%{_libdir}/chromium-browser/themes/
%{_pixmapsdir}/chromium-browser.png
%{_desktopdir}/*.desktop
