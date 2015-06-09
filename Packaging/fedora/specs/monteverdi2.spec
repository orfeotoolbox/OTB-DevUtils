# spec file for Monteverdi2
%global _uname Monteverdi2

Name:  monteverdi2
Version:  0.9.0
Release:  1%{?dist}
Summary:  %{sname} is the GUI interface built with OTB library and Qt
Group:    Applications/Engineering
License:  CeCILL
URL:	  http://www.orfeo-toolbox.org
Source0:  http://orfeo-toolbox.org/packages/%{_uname}-%{version}.tgz
BuildRequires:  fltk-devel
BuildRequires:  fltk-fluid
BuildRequires:  cmake
BuildRequires:  otb-devel >= 4.5.0
BuildRequires:  glfw-devel
BuildRequires:  glew-devel
BuildRequires:  freeglut-devel
BuildRequires:  libXmu-devel
BuildRequires:  gdal-devel >= 1.11.2
BuildRequires:  boost-devel
BuildRequires:  InsightToolkit-devel >= 4.7
BuildRequires:  ossim-devel >= 1.8.18
BuildRequires: libgeotiff-devel
BuildRequires: libpng-devel
BuildRequires: boost-devel
BuildRequires: expat-devel
BuildRequires: curl-devel
BuildRequires: tinyxml-devel
BuildRequires: muParser-devel
BuildRequires: OpenThreads-devel
BuildRequires: libjpeg-turbo-devel
BuildRequires: openjpeg2-devel >= 2.1.0-4
BuildRequires: openjpeg2-tools >= 2.1.0-4
### test package to install only jpeg plugin
###BuildRequires: gdal-openjpeg
#for generating man pages from help
BuildRequires: help2man
BuildRequires: opencv-devel
BuildRequires:  zlib-devel
##build requires from itk
BuildRequires:  gdcm-devel
BuildRequires:  vxl-devel
BuildRequires:  python2-devel
BuildRequires:  otb-ice-devel >= 0.2.0
BuildRequires:  qwt5-qt4-devel

%description
%{sname} is the GUI interface built with OTB library and Qt

%prep
%setup -q -n %{_uname}-%{version}

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. \
       -DCMAKE_INSTALL_PREFIX:PATH=%{_prefix} \
       -DBUILD_TESTING:BOOL=OFF \
       -DQWT_LIBRARY:FILEPATH=%{_libdir}/libqwt5-qt4.so \
       -DQWT_INCLUDE_DIR:PATH=%{_includedir}/qwt5-qt4/ \
       -DMonteverdi2_INSTALL_LIB_DIR:PATH=%{_lib}/otb \
       -DMONTEVERDI2_OUTPUT_NAME:STRING="monteverdi2.bin"
popd
make %{?_smp_mflags} -C %{_target_platform}

%install
rm -rf %{buildroot}
%make_install -C %{_target_platform}


%post
cat > /usr/bin/monteverdi2 <<EOF
export ITK_AUTOLOAD_PATH=%{_libdir}/otb/applications
/usr/bin/monteverdi2.bin $@
EOF

/sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_libdir}/otb/libMonteverdi2*
%{_bindir}/monteverdi2.bin
%{_bindir}/mapla
%{_datadir}/otb/*
%{_datadir}/icons/*
%{_datadir}/pixmaps/*
%{_datadir}/applications/*
%dir %{_libdir}/otb
%dir %{_datadir}/icons
%dir %{_datadir}/pixmaps
%dir %{_datadir}/applications
%dir %{_datadir}/icons/hicolor
%dir %{_datadir}/icons/hicolor/16x16
%dir %{_datadir}/icons/hicolor/32x32
%dir %{_datadir}/icons/hicolor/48x48
%dir %{_datadir}/icons/hicolor/128x128


%changelog
* Wed Apr 29 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.9.0-1
- use _datadir/share instead of adding _sharedir variable

* Tue Apr 28 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.9.0-1
- update for OTB-4.5.0

* Tue Dec 23 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.8.0-1
- Initial package for Monteverdi2

* Wed Nov 19 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.8.0-1
- add launcher script to set ITK_AUTOLOAD_PATH
