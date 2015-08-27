#
# spec file for package insighttoolkit
#
# Copyright (c) 2015 Angelos Tzotsos <tzotsos@opensuse.org>.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/

# norootforbuild

%define tarname InsightToolkit

Name:           insighttoolkit
Version:        4.7.2
Release:        1
Summary:        Insight Segmentation and Registration Toolkit
Group:          Development/Libraries
License:        Apache-2
URL:            http://www.itk.org
Source0:        %{tarname}-%{version}.tar.gz
Patch0:         nrrdio-linking.patch
Patch1:         make-gdcm-helper-library-static.patch
Patch2:         dl-close-fix.patch
Patch3:         doubleconv.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:	cmake >= 2.8.0
BuildRequires:  gcc-c++ 
BuildRequires:  gcc
BuildRequires:  swig
# BuildRequires:  gccxml
BuildRequires:  zlib-devel
BuildRequires:  libpng-devel
BuildRequires:  libtiff-devel
BuildRequires:  fftw3-devel
BuildRequires:  fftw3-threads-devel
BuildRequires:  dcmtk-devel
# BuildRequires:  gdcm-devel
# BuildRequires:  libuuid-devel
BuildRequires:  hdf5-devel
BuildRequires:  python-devel
BuildRequires:  vtk-devel
BuildRequires:  python-vtk
BuildRequires:  libjpeg-devel
BuildRequires:  libexpat-devel
BuildRequires:  sed
BuildRequires:  fdupes


%description
ITK is an open-source, cross-platform system that provides developers with an extensive suite of software tools for image analysis

%package devel
Summary:        Development files for ITK
Group:          Development/Libraries
Requires:       lib%{name}4 = %{version}
Provides:       lib%{name}-devel

%description devel
Development files for the ITK library. ITK is an open-source, cross-platform system that provides developers with an extensive suite of software tools for image analysis

%package -n lib%{name}4
Summary:        ITK static libraries
Group:          System/Libraries

%description -n lib%{name}4
Shared ITK library. ITK is an open-source, cross-platform system that provides developers with an extensive suite of software tools for image analysis.

%prep
%setup -q -n %{tarname}-%{version}
%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1

%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_EXAMPLES:BOOL=ON \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_TESTING:BOOL=OFF \
       -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
       -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DUSE_FFTWF=ON \
       -DITK_USE_FFTWD:BOOL=ON \
       -DITK_USE_FFTWF:BOOL=ON \
       -DITK_USE_SYSTEM_FFTW:BOOL=ON \
       -DITK_USE_STRICT_CONCEPT_CHECKING:BOOL=ON \
       -DITK_USE_SYSTEM_DOUBLECONVERSION:BOOL=OFF \
       -DITK_USE_SYSTEM_DCMTK:BOOL=ON \
       -DITK_USE_SYSTEM_GDCM:BOOL=OFF \
       -DITK_USE_SYSTEM_HDF5:BOOL=ON \
       -DITK_USE_SYSTEM_JPEG:BOOL=ON \
       -DITK_USE_SYSTEM_PNG:BOOL=ON \
       -DITK_USE_SYSTEM_TIFF:BOOL=ON \
       -DITK_USE_SYSTEM_VXL:BOOL=OFF \
       -DITK_USE_SYSTEM_ZLIB:BOOL=ON \
       -DITK_USE_SYSTEM_GCCXML:BOOL=OFF \
       -DITK_USE_SYSTEM_SWIG:BOOL=ON \
       -DITK_USE_SYSTEM_EXPAT:BOOL=ON \
       -DModule_ITKDCMTK:BOOL=ON \
       -DModule_ITKIOPhilipsREC:BOOL=OFF \
       -DModule_ITKLevelSetsv4Visualization:BOOL=OFF \
       -DModule_ITKReview:BOOL=OFF \
       -DModule_ITKVideoBridgeOpenCV:BOOL=OFF \
       -DModule_ITKVideoBridgeVXL:BOOL=OFF \
       -DModule_ITKVtkGlue:BOOL=OFF \
       -DModule_ITKDeprecated:BOOL=OFF \
       -DITKV3_COMPATIBILITY:BOOL=ON \
       -DVCL_INCLUDE_CXX_0X:BOOL=ON \
       -DITK_WRAP_DIMS="2;3;4" \
       -DITK_WRAP_double:BOOL=ON \
       -DITK_WRAP_vector_double:BOOL=ON \
       -DITK_WRAP_covariant_vector_double:BOOL=ON \
       -DITK_WRAP_complex_double:BOOL=ON \
       -DITK_WRAPPING:BOOL=OFF \
       -DITK_WRAP_PYTHON:BOOL=OFF \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{tarname}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}

%if "%{_lib}" == "lib64"
mkdir -p %{buildroot}/usr/lib64
mv %{buildroot}/usr/lib/* %{buildroot}/usr/lib64/
sed -i 's|/lib/|/lib64/|g' %{buildroot}/usr/lib64/cmake/ITK-4.7/ITKConfig.cmake
sed -i 's|/lib/|/lib64/|g' %{buildroot}/usr/lib64/cmake/ITK-4.7/ITKTargets.cmake
sed -i 's|/lib/|/lib64/|g' %{buildroot}/usr/lib64/cmake/ITK-4.7/ITKTargets-release.cmake
%endif
rm -rf %{buildroot}/usr/lib/debug

%fdupes %{buildroot}


%clean
rm -rf %{buildroot}

%post -n lib%{name}4 -p /sbin/ldconfig

%postun -n lib%{name}4 -p /sbin/ldconfig

%files -n lib%{name}4
%defattr(644,root,root,755)
# %dir %{_libdir}/
%{_libdir}/*.so.1


%files devel
%defattr(-,root,root,-)
%{_includedir}/*
%{_libdir}/lib*.so
%{_libdir}/cmake/
%{_bindir}/itkTestDriver
%{_datadir}/*

%changelog
