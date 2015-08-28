#
# spec file for package otb-ice
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

%define tarname Ice 

Name:           otb-ice
Version:        0.3.0
Release:        1
Summary:        A fast OpenGL rendering library for remote sensing images
Group:          Development/Libraries
License:        CECILL-2.0
URL:            http://www.orfeo-toolbox.org
Source0:        %{tarname}-%{version}.tgz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake >= 2.8.0
BuildRequires:  gcc-c++
BuildRequires:  gcc
BuildRequires:  fdupes
BuildRequires:  otb-devel
BuildRequires:  otb otb-qt
BuildRequires:  glew-devel
BuildRequires:  libglfw-devel

%description
A fast OpenGL rendering library for remote sensing images.
OTB ICE is a fast OpenGL rendering library for remote sensing images. This
small piece of code decomposes into an OTB/OpenGL only library with an API
for simple rendering of remote sensing images and a GLFW3 example of how to
use the API.


%package devel
Summary:        A fast OpenGL rendering library for remote sensing images
Group:          Development/Libraries
Requires:       libOTBIce0_3 = %{version}
Provides:       lib%{name}-devel


%description devel
A fast OpenGL rendering library for remote sensing images - Development files.
OTB ICE is a fast OpenGL rendering library for remote sensing images. This
small piece of code decomposes into an OTB/OpenGL only library with an API
for simple rendering of remote sensing images and a GLFW3 example of how to
use the API.


%package -n libOTBIce0_3
Summary:        ORFEO Toolbox shared library of image processing algorithms
Group:          System/Libraries

%description -n libOTBIce0_3
A fast OpenGL rendering library for remote sensing images - Shared Library.
OTB ICE is a fast OpenGL rendering library for remote sensing images. This
small piece of code decomposes into an OTB/OpenGL only library with an API
for simple rendering of remote sensing images and a GLFW3 example of how to
use the API.


%prep
%setup -q -n %{tarname}-%{version}

%build
cd ..
mkdir temp
cd temp
cmake  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DBUILD_ICE_APPLICATION:BOOL=OFF \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DBUILD_TESTING:BOOL=OFF \
       -DCMAKE_BUILD_TYPE:STRING=Release ../%{tarname}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}

%if "%{_lib}" == "lib64"
mkdir -p %{buildroot}/usr/lib64
mv %{buildroot}/usr/lib/* %{buildroot}/usr/lib64/
%endif

%fdupes %{buildroot}


%clean
rm -rf %{buildroot}

%post -n libOTBIce0_3 -p /sbin/ldconfig

%postun -n libOTBIce0_3 -p /sbin/ldconfig

%files -n libOTBIce0_3
%defattr(644,root,root,755)
%{_libdir}/*.so.*

%files devel
%defattr(-,root,root,-)
%{_includedir}/*.h
%{_libdir}/lib*.so

%changelog
