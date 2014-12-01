# spec file for Monteverdi2
%global sname Monteverdi2
Name:  monteverdi2
Version:  0.8.0
Release:  1%{?dist}
Summary:  A GUI application developed around OTB library and Qt
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
BuildRequires:  InsightToolkit-devel
BuildRequires:  ossim-devel
BuildRequires: libgeotiff-devel 
BuildRequires: libpng-devel 
BuildRequires: boost-devel
BuildRequires: expat-devel 
BuildRequires: curl-devel
BuildRequires: tinyxml-devel 
BuildRequires: muParser-devel
BuildRequires: OpenThreads-devel
BuildRequires: libjpeg-devel
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
BuildRequires:  desktop-file-utils

%description
This package provides %{sname} GUI application developed 
in Qt4 around the OTB library.

%prep
%setup -q -n %{sname}-%{version} -D

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. \
    -DQWT_LIBRARY:FILEPATH=%{_libdir}/libqwt5-qt4.so \
    -DQWT_INCLUDE_DIR:PATH=%{_includedir}/qwt5-qt4/ \
    -DMonteverdi2_INSTALL_LIB_DIR:PATH=%{_lib}/otb
popd
make %{?_smp_mflags} -C %{_target_platform}

%install
%make_install -C %{_target_platform}
desktop-file-install                                    \
--add-category="Science"                          \
--delete-original                                       \
--dir=%{buildroot}%{_datadir}/applications              \
%{buildroot}/%{_datadir}/applications/monteverdi2.desktop

%check
desktop-file-validate %{buildroot}/%{_datadir}/applications/monteverdi2.desktop

%post
/bin/touch --no-create %{_datadir}/icons/hicolor &>/dev/null || :
/sbin/ldconfig

%postun
if [ $1 -eq 0 ] ; then
    /bin/touch --no-create %{_datadir}/icons/hicolor &>/dev/null
    /usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor &>/dev/null || :
fi
/sbin/ldconfig

%posttrans
/usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor &>/dev/null || :

%files
%{_libdir}/otb/libMonteverdi2*.so.*
%{_bindir}/monteverdi2
%{_datadir}/otb/*
%{_datadir}/icons/*
%{_datadir}/pixmaps/*
%{_datadir}/applications/monteverdi2.desktop
%exclude %{_libdir}/otb/libMonteverdi2*.so
%exclude %{_datadir}/applications/mvd2-viewer.desktop

%changelog
* Mon Dec 1 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.8.0-1
- update for Fedora Guidelines as suggested by Volter
- install and validate .desktop file. 
- updating icon cache in post and postun

* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.8.0-1
- Initial package for Monteverdi2
