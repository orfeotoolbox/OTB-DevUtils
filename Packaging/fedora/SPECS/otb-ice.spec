# spec file for otb-ice
# norootforbuild
Name:  otb-ice
Version:  0.4.0
Release:  1%{?dist}
%global other_name Ice
Summary:  %{name} is a fast OpenGL rendering engine for OTB
Group:	       System Environment/Libraries
License:       CeCILL
URL:	       http://www.orfeo-toolbox.org
Source0:       http://orfeo-toolbox.org/packages/%{other_name}-%{version}.tar.gz

BuildRequires: cmake
BuildRequires: otb-devel >= 5.2
BuildRequires: glfw-devel
BuildRequires: glew-devel
BuildRequires: freeglut-devel
BuildRequires: libXmu-devel
#F21
#BuildRequires: InsightToolkit-otb-devel >= 4.7.1

BuildRequires: gdal-devel >= 1.11.2

#OTB 5.2
#BuildRequires: ossim-devel >= 1.8.20

BuildRequires: ossim-devel >= 1.8.18

#F22+
BuildRequires:  InsightToolkit-devel >= 4.7.1
BuildRequires: InsightToolkit-vtk  >= 4.7.1

BuildRequires: libgeotiff-devel
BuildRequires: libpng-devel
BuildRequires: boost-devel
BuildRequires: expat-devel
BuildRequires: curl-devel
BuildRequires: tinyxml-devel
BuildRequires: muParser-devel
BuildRequires: OpenThreads-devel
BuildRequires: opencv-devel
BuildRequires:  zlib-devel
#build requires from itk   F22+
BuildRequires:  gdcm-devel
BuildRequires:  vxl-devel
BuildRequires:  python2-devel
BuildRequires:  fftw-devel

%description
%{name} is a fast OpenGL rendering API for remote sensing images.
This small piece of code decomposes into an OTB/OpenGl only library
with an API for simple rendering of remote sensing images
and a GLFW3 example of how to use the API.

It is the fastest renderer available for very high resolution imagery.

%package        devel
Summary:	Development files for %{name}
Group:		Development/Libraries
Requires:	%{name} = %{version}

%description    devel
Development files for the %{name} library.

%package        doc
Summary:	Documentation files for %{name}
Group:		Documentation
Requires:	%{name} = %{version}

%description    doc
Documentation files for the %{name} library.

%prep
%setup -q -n %{other_name}-%{version}

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DIce_INSTALL_LIB_DIR:PATH=%{_lib} \
    -DITK_DIR:PATH=%{_libdir}/cmake/InsightToolkit \
    -DOTB_DIR:PATH=%{_libdir}/cmake/OTB-5.2 \
    -DBUILD_ICE_APPLICATION:BOOL=ON \
    -DCMAKE_BUILD_TYPE:STRING="RelWithDebInfo"
popd
make %{?_smp_mflags} -C %{_target_platform}

%install
rm -rf %{buildroot}
%make_install -C %{_target_platform}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_libdir}/lib*.so*
%{_bindir}/*viewer

%files devel
%{_libdir}/lib*.so*
%{_includedir}/otb*.h

%files doc
%doc Copyright.txt
%doc README


%changelog
* Mon Dec 28 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.4.0-1
- new upstream release 0.4.0
* Fri Oct 30 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.3.0-2
- Fix ITK_DIR
* Fri Oct 30 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.3.0-2
- clean up build requires
* Fri Oct 30 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.3.0-2
- update for Fedora 21
* Mon Jun 15 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.3.0-1
- update for Ice 0.3.0
* Tue Apr 28 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 0.2.0-1
- update for OTB 4.5.0
- added a doc section with Copyright.txt and README
- commented out BuildRequires from depedencies
- check for OTB, ITK version
* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - bde0f85ca45dsnap
- Initial package for OTB Ice
