#
# spec file for package Monteverdi2
#
# Copyright (c) 2014 Angelos Tzotsos <tzotsos@opensuse.org>.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the Monteverdi2 package itself (unless the
# license for the Monteverdi2 package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/

# norootforbuild

Name:           Monteverdi2
Version:        0.6.0
Release:        1
Summary:        New generation application based on OrfeoToolbox for remote sensing image processing
Group:          Development/Libraries
License:        CECILL-2.0
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tgz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake 
BuildRequires:  libgdal-devel 
BuildRequires:  libgeotiff-devel 
BuildRequires:  gcc-c++ 
BuildRequires:  gcc 
BuildRequires:  gettext-runtime 
BuildRequires:  gettext-tools 
BuildRequires:  freeglut-devel 
BuildRequires:  libpng-devel
BuildRequires:  fdupes 
BuildRequires:  OrfeoToolbox-devel 
BuildRequires:  libOpenThreads-devel 
BuildRequires:  boost-devel
BuildRequires:  libqt4-devel
BuildRequires:  qwt6-devel

%description
%{name} is a image processing application developed by CNES in the frame of the ORFEO Accompaniment Program

%prep
%setup -q

%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_TESTING:BOOL=OFF \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DOTB_DIR:PATH=%{_libdir}/otb \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 

%install
cd ../temp
make install DESTDIR=%{buildroot}
#%if "%{_lib}" == "lib64"  
#mkdir %{buildroot}/usr/%{_lib}
#mv %{buildroot}/usr/lib/otb %{buildroot}/usr/%{_lib}/
#%endif
%fdupes %{buildroot}

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_bindir}/*
#%{_libdir}/otb/
#%{_libdir}/otb/lib*
%{_datadir}/applications/*.desktop
%{_datadir}/pixmaps/monteverdi.*

%changelog

