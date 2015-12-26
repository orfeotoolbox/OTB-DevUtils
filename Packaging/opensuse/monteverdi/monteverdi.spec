#
# spec file for package monteverdi
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

%define tarname Monteverdi 

Name:           monteverdi
Version:        3.0.0
Release:        1
Summary:        Application based on OrfeoToolbox (OTB) for remote sensing image processing
Group:          Development/Libraries
License:        CECILL-2.0
URL:            http://www.orfeo-toolbox.org
Source0:        %{tarname}-%{version}.tar.gz
Patch0:         qwt_find.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake >= 2.8.0
BuildRequires:  libotb-devel
BuildRequires:  otb-ice-devel
BuildRequires:  gcc-c++
BuildRequires:  gcc
BuildRequires:  libqt4-devel 
BuildRequires:  glew-devel
BuildRequires:  qwt-devel
BuildRequires:  fdupes

%description
Image processing workshop based on the OTB library
Monteverdi is an image processing workshop based on the OTB library. It takes
advantage of the streaming and multi-threading capabilities of the OTB
pipeline. It also uses cool features as processing on demand and automagic
file format I/O. Monteverdi is distributed under a free software license
CeCILL (similar to GNU GPL) to encourage contribution from users and to
promote reproducible research.

%package -n lib%{name}3
Summary:        Visualisation library based on legacy OTB/FLTK widgets
Group:          System/Libraries
Obsoletes:      Monteverdi

%description -n lib%{name}3
Visualisation library based on legacy OTB/FLTK widgets
Monteverdi is an image processing workshop based on the OTB library. It takes
advantage of the streaming and multi-threading capabilities of the OTB
pipeline. It also uses cool features as processing on demand and automagic
file format I/O. Monteverdi is distributed under a free software license
CeCILL (similar to GNU GPL) to encourage contribution from users and to
promote reproducible research.

%package devel
Summary:        Visualisation library based on legacy OTB/FLTK widgets
Group:          System/Libraries
Obsoletes:      Monteverdi
Requires:       lib%{name}3 = %{version}

%description devel
Visualisation library based on legacy OTB/FLTK widgets - development files
Monteverdi is an image processing workshop based on the OTB library. It takes
advantage of the streaming and multi-threading capabilities of the OTB
pipeline. It also uses cool features as processing on demand and automagic
file format I/O. Monteverdi is distributed under a free software license
CeCILL (similar to GNU GPL) to encourage contribution from users and to
promote reproducible research.

%prep
%setup -q -n %{tarname}-%{version}
%patch0 -p1

%build
cd ..
mkdir temp
cd temp
cmake  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{tarname}-%{version}/

make VERBOSE=1


%install
cd ../temp
make install DESTDIR=%{buildroot}

%if "%{_lib}" == "lib64"  
mkdir %{buildroot}/usr/%{_lib}
mv %{buildroot}/usr/lib/otb %{buildroot}/usr/%{_lib}/
%endif
%fdupes %{buildroot}

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_datadir}/applications/*.desktop
%{_datadir}/pixmaps/monteverdi*
%{_datadir}/icons/*
%dir %{_datadir}/otb/
%{_datadir}/otb/*

%files -n lib%{name}3
%defattr(644,root,root,755)
%{_libdir}/otb/lib*.so.*

%files devel
%defattr(-,root,root,-)
%{_libdir}/otb/lib*.so

%changelog

