# spec file for Monteverdi2
%global _prefix /usr
%global sname Monteverdi2
%global _sharedir %{_prefix}/share

Name:  monteverdi2
Version:  0.8.0
Release:  1%{?dist}
Summary:  %{sname} is the GUI interface built with OTB library and Qt
Group:    Applications/Engineering
License:  CeCILL
URL:	  http://www.orfeo-toolbox.org
Source0:  http://orfeo-toolbox.org/packages/%{sname}-%{version}.tgz
BuildRequires:  fltk-devel
BuildRequires:  fltk-fluid
BuildRequires:  cmake
BuildRequires:  otb-devel
BuildRequires:  glfw-devel
BuildRequires:  glew-devel
BuildRequires:  freeglut-devel
BuildRequires:  libXmu-devel
BuildRequires:  gdal-devel 
BuildRequires:  boost-devel
BuildRequires:  InsightToolkit-devel >= 4.6
BuildRequires:  ossim-devel
BuildRequires: libgeotiff-devel 
BuildRequires: libpng-devel 
BuildRequires: boost-devel
BuildRequires: expat-devel 
BuildRequires: curl-devel
BuildRequires: tinyxml-devel 
BuildRequires: muParser-devel
BuildRequires: OpenThreads-devel
BuildRequires: libjpeg-turbo-devel
BuildRequires: openjpeg2-devel
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
BuildRequires:  otb-Ice-devel
BuildRequires:  qwt5-qt4-devel

%description
%{sname} is the GUI interface built with OTB library and Qt

%prep
%setup -q -n %{sname}-%{version} -D

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. \
    -DCMAKE_INSTALL_PREFIX:PATH=%{_prefix} \
    -DQWT_LIBRARY:FILEPATH=%{_libdir}/libqwt5-qt4.so \
    -DQWT_INCLUDE_DIR:PATH=%{_includedir}/qwt5-qt4/ \
    -DMonteverdi2_INSTALL_LIB_DIR:PATH=%{_lib}/otb
popd
make %{?_smp_mflags} -C %{_target_platform}

%install
rm -rf %{buildroot}
%make_install -C %{_target_platform}


%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_libdir}/otb/libMonteverdi2*
%{_bindir}/monteverdi2
%{_sharedir}/otb/*
%{_sharedir}/icons/*
%{_sharedir}/pixmaps/*
%{_sharedir}/applications/*
%dir %{_libdir}/otb
%dir %{_sharedir}/icons
%dir %{_sharedir}/pixmaps
%dir %{_sharedir}/applications
%dir %{_sharedir}/icons/hicolor
%dir %{_sharedir}/icons/hicolor/16x16
%dir %{_sharedir}/icons/hicolor/32x32
%dir %{_sharedir}/icons/hicolor/48x48
%dir %{_sharedir}/icons/hicolor/128x128


%changelog
* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.8.0-1
- Initial package for Monteverdi2
