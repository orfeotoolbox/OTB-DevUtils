# spec file for OTB Ice
# norootforbuild
%define sname Ice
Name:  otb-%{sname}
Version:  bde0f85ca45d
Release:  1%{?dist}
Summary:  %{sname} is a fast OpenGL rendering engine for OTB 
Group:	       System Environment/Libraries
License:       CeCILL
URL:	       http://www.orfeo-toolbox.org
Source0:       http://orfeo-toolbox.org/packages/%{sname}-%{version}.tgz

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

%description
%{sname} is a fast OpenGL rendering API for remote sensing images. 
This small piece of code decomposes into an OTB/OpenGl only library 
with an API for simple rendering of remote sensing images 
and a GLFW3 example of how to use the API.

It is the fastest renderer available for very high resolution imagery.

%package        devel
Summary:	Development files for %{sname}
Group:		Development/Libraries
Requires:	%{name} = %{version}

%description    devel
Development files for the %{sname} library. 

%prep
%setup -q -n %{sname}-%{version}

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. \
    -DIce_INSTALL_LIB_DIR:PATH=%{_lib}/otb \
    -DCMAKE_BUILD_TYPE:STRING="RelWithDebInfo"
popd
make %{?_smp_mflags} -C %{_target_platform}

%install
%make_install -C %{_target_platform}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_libdir}/otb/*.so.*
%{_bindir}/*viewer
%dir %{_libdir}/otb

%files devel
%{_libdir}/otb/*.so*
%{_includedir}/otb/
%dir %{_includedir}/otb/
%dir %{_libdir}/otb

%changelog
* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - bde0f85ca45dsnap
- Initial package for OTB Ice
