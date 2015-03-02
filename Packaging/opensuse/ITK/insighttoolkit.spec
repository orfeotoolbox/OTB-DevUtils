#
# spec file for package ITK
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
Version:        4.6.0
Release:        1
Summary:        Insight Segmentation and Registration Toolkit
Group:          Development/Libraries
License:        Apache-2
URL:            http://www.itk.org
Source0:        %{tarname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:	cmake >= 2.8.0
BuildRequires:  libtiff-devel
BuildRequires:  libpng-devel
BuildRequires:  libjpeg-devel
BuildRequires:  fftw3-devel
BuildRequires:  fftw3-threads-devel
BuildRequires:  gcc-c++ 
BuildRequires:  gcc
BuildRequires:  swig
BuildRequires:  libexpat-devel
BuildRequires:  hdf5-devel
BuildRequires:  zlib-devel
BuildRequires:  fdupes


%description
ITK is an open-source, cross-platform system that provides developers with an extensive suite of software tools for image analysis

%package devel
Summary:        Development files for ITK
Group:          Development/Libraries
Requires:       lib%{name}1 = %{version}
Provides:       lib%{name}-devel

%description devel
Development files for the ITK library. ITK is an open-source, cross-platform system that provides developers with an extensive suite of software tools for image analysis

%package -n lib%{name}1
Summary:        ITK static libraries
Group:          System/Libraries

%description -n lib%{name}1
Static ITK library. ITK is an open-source, cross-platform system that provides developers with an extensive suite of software tools for image analysis.

%prep
%setup -q -n %{tarname}-%{version}

%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_EXAMPLES:BOOL=OFF \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_TESTING:BOOL=OFF \
       -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
       -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON \
       -DITKV3_COMPATIBILITY:BOOL=OFF \
       -DITK_BUILD_DEFAULT_MODULES:BOOL=ON \
       -DITK_WRAP_PYTHON:BOOL=OFF \
       -DITK_USE_SYSTEM_FFTW:BOOL=ON \
       -DITK_USE_SYSTEM_HDF5:BOOL=ON \
       -DITK_USE_SYSTEM_JPEG:BOOL=ON \
       -DITK_USE_SYSTEM_PNG:BOOL=ON \
       -DITK_USE_SYSTEM_TIFF:BOOL=ON \
       -DITK_USE_SYSTEM_ZLIB:BOOL=ON \
       -DITK_USE_SYSTEM_SWIG:BOOL=ON \
       -DZLIB_USE_EXTERNAL:BOOL=ON \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_SKIP_RPATH:BOOL=OFF \
       -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{tarname}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}

%if "%{_lib}" == "lib64"
mkdir -p %{buildroot}/usr/lib64
mv %{buildroot}/usr/lib/* %{buildroot}/usr/lib64/
%endif
rm -rf %{buildroot}/usr/lib/debug

%fdupes %{buildroot}


%clean
rm -rf %{buildroot}

%post -n lib%{name}1 -p /sbin/ldconfig

%postun -n lib%{name}1 -p /sbin/ldconfig

%files -n lib%{name}1
%defattr(644,root,root,755)
# %dir %{_libdir}/
# %{_libdir}/lib*.so.*
# %{_libdir}/*.so.1.*
%{_libdir}/*.so.1

%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_datadir}/*

%files devel
%defattr(-,root,root,-)
%{_includedir}/*
%{_libdir}/lib*.so
%{_libdir}/cmake/

%changelog
