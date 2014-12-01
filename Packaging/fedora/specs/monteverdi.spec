# spec file for Monteverdi
# norootforbuild
%global sname Monteverdi
Name:  monteverdi
Version:  1.22.0
Release:  1%{?dist}
Summary:  A GUI application developed around OTB library and FLTK
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
BuildRequires:  desktop-file-utils

%description
This package provides %{sname} GUI application developed in 
FLTK around the OTB library.

%prep
%setup -q -n %{sname}-%{version} -D

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. -DMonteverdi_INSTALL_LIB_DIR:PATH=%{_lib}/otb
popd
make %{?_smp_mflags} -C %{_target_platform}

%install
%make_install -C %{_target_platform}
desktop-file-install                                    \
--add-category="Science"                          \
--delete-original                                       \
--dir=%{buildroot}%{_datadir}/applications              \
%{buildroot}/%{_datadir}/applications/monteverdi.desktop

%check
desktop-file-validate %{buildroot}/%{_datadir}/applications/monteverdi.desktop

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_bindir}/monteverdi
%{_bindir}/otbViewer
%{_libdir}/otb/*.so*
%{_datadir}/pixmaps/monteverdi.*
%{_datadir}/applications/monteverdi.desktop
%exclude %{_libdir}/otb/*.cmake
%exclude %{_includedir}
%exclude %{_libdir}/otb/*.so


%changelog
* Mon Dec 1 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 1.22.0-1
- update for Fedora Guidelines as suggested by Volter
- updated description for OTB and sub-packages
- install and validate .desktop file. 
- updating icon cache in post and postun

* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 1.22.0-1
- Initial package for Monteverdi
