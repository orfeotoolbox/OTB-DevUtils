# spec file for Monteverdi
# norootforbuild
%global _prefix /usr
%global sname Monteverdi
%global _sharedir %{_prefix}/share

Name:  monteverdi
Version:  1.22.0
Release:  1%{?dist}
Summary:  %{sname} is the GUI interface built with OTB library and FLTK
Group:    Applications/Engineering
License:  CeCILL
URL:	  http://www.orfeo-toolbox.org
Source0:  http://orfeo-toolbox.org/packages/%{sname}-%{version}.tgz
BuildRequires:  gcc-c++ 
BuildRequires:  gcc
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

%description
%{sname} is the GUI interface built with OTB library and FLTK

It allows building processing chains by selecting modules 
from a set of menus. It supports raster and vector data and 
gives access to OTB functionalities in a modular architecture. 
It is built using OTB library and which provides streaming 
and multi-threading capabilities.

%prep
%setup -q -n %{sname}-%{version} -D

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DMonteverdi_INSTALL_LIB_DIR:PATH=%{_lib}/otb

popd
make %{?_smp_mflags} -C %{_target_platform}

%install
rm -rf %{buildroot}
%make_install -C %{_target_platform}


%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_bindir}/monteverdi
%{_bindir}/otbViewer
%{_libdir}/otb/libOTBVisuFLTK.so*
%{_libdir}/otb/libOTBGuiFLTK.so*
%{_libdir}/otb/libOTBVisuLegacyFLTK.so*
%{_libdir}/otb/libotb*Module*
%{_libdir}/otb/libOTBMonteverdi*.so*
%{_libdir}/otb/libotbMonteverdi.so*
%{_libdir}/otb/libflu.so*
%{_sharedir}/pixmaps/monteverdi.*
%{_sharedir}/applications/monteverdi.desktop

%dir %{_libdir}/otb
%dir %{_sharedir}/pixmaps
%dir %{_sharedir}/applications

%exclude %{_libdir}/otb/Monteverd*.cmake
%exclude %{_includedir}/

%changelog
* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 1.22.0-1
- Initial package for Monteverdi
