# spec from  http://spot.fedorapeople.org/chromium/

%global svndate 20090711
%global svnver  svn20464

Summary:	A WebKit powered web browser
Name:		chromium
Version:	3.0.194.0
Release:	0.1.%{svndate}%{svnver}%{?dist}
License:	BSD
Group:		Applications/Networking
# see src/chrome/VERSION
Patch0:		%{name}-20090711-system-bz2-xml2-xslt-zlib-minizip-libevent-jpeg-png-nss-nspr-v8.patch
# Use chromium-daily-tarball.sh to generate tarball.
Source0:	%{name}-%{svndate}%{svnver}.tar.bz2
# Custom build tools for chromium, hammer is a fancy front-end for scons
Source1:	http://src.chromium.org/svn/trunk/tools/depot_tools.tar.gz
Source2:	%{name}-browser.sh
Source3:	%{name}-browser.desktop
# We don't actually use this in the build, but it is included so you can make the tarball.
Source4:	%{name}-daily-tarball.sh
BuildRequires:	bzip2-devel
BuildRequires:	libevent-devel
BuildRequires:	libjpeg-devel
BuildRequires:	libpng-devel
BuildRequires:	desktop-file-utils
BuildRequires:	gperf
BuildRequires:	flex
BuildRequires:	gtk2-devel
BuildRequires:	atk-devel
BuildRequires:	v8-devel
BuildRequires:	scons
BuildRequires:	gcc-c++
BuildRequires:	bison
BuildRequires:	fontconfig-devel
BuildRequires:	GConf2-devel
BuildRequires:	dbus-devel
BuildRequires:	alsa-lib-devel
BuildRequires:	libxslt-devel
BuildRequires:	nss-devel
BuildRequires:	nspr-devel
BuildRequires:	minizip-devel
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)
# Chromium bits don't compile on x86_64.
ExclusiveArch:	%{ix86} arm

%description
Chromium is an open-source web browser, powered by WebKit.

%prep
%setup -q -n %{name}-%{svndate}%{svnver} -a 1
cp %{SOURCE4} .

# Somehow, path noise from the tarball creation got embedded.
# Thanks gclient. :P
# FIXME: Figure out how to avoid this
for i in `find . |grep "\.scons"`; do
	sed -i "s|/home/spot/sandbox/chromium-%{svndate}/|%{_builddir}/chromium-%{svndate}%{svnver}/|g" $i
done

# Patch in support for system libs
# bz2, xml2, xslt, zlib, minizp, event, jpeg, png, nss, nspr, v8
%patch0 -p1 -b .system

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
