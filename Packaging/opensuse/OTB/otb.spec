#
# spec file for package otb
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

%define tarname OTB 

Name:           otb
Version:        5.2.0
Release:        1
Summary:        The ORFEO Toolbox (OTB) is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        CECILL-2.0
URL:            http://www.orfeo-toolbox.org
Source0:        %{tarname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake >= 2.8.0
BuildRequires:  gcc-c++
BuildRequires:  gcc
BuildRequires:  insighttoolkit-devel
BuildRequires:  gdal-devel
BuildRequires:  libgdal1
BuildRequires:  libgeotiff-devel
BuildRequires:  libtool
BuildRequires:  libcurl-devel
BuildRequires:  libOpenThreads-devel
BuildRequires:  boost-devel
BuildRequires:  libqt4-devel
BuildRequires:  swig
BuildRequires:  python-devel
BuildRequires:  libsvm-devel
BuildRequires:  libsvm2
BuildRequires:  muparser-devel
BuildRequires:  muparserx-devel
BuildRequires:  opencv-devel
BuildRequires:  ossim-devel
BuildRequires:  tinyxml-devel
BuildRequires:  libproj-devel
BuildRequires:  fdupes
Obsoletes:      OrfeoToolbox


%description
ORFEO Toolbox (OTB) is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program.
ORFEO Toolbox is distributed as an open source library of image
processing algorithms. OTB is based on the medical image processing library
ITK and offers particular functionalities for remote sensing image processing
in general and for high spatial resolution images in particular. OTB is
distributed under a free software license CeCILL (similar to GNU GPL) to
encourage contribution from users and to promote reproducible research.
This package contains the command line tools illustrating OTB features.

%package devel
Summary:        ORFEO Toolbox development files
Group:          Development/Libraries
Requires:       lib%{name}5 = %{version}
Provides:       lib%{name}-devel
Obsoletes:      OrfeoToolbox-devel
Requires:       cmake
Requires:       gcc-c++
Requires:       gcc
Requires:       insighttoolkit-devel
Requires:       gdal-devel
Requires:       libgdal1
Requires:       libgeotiff-devel
Requires:       libOpenThreads-devel
Requires:       boost-devel
Requires:       libsvm-devel
Requires:       libsvm2
Requires:       muparser-devel
Requires:       muparserx-devel
Requires:       opencv-devel
Requires:       ossim-devel
Requires:       libcurl-devel
Requires:       tinyxml-devel
Requires:       libqt4-devel
Requires:       libtool


%description devel
ORFEO Toolbox development files.
ORFEO Toolbox (OTB) is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program. 
ORFEO Toolbox is distributed as an open source library of image
processing algorithms. OTB is based on the medical image processing library
ITK and offers particular functionalities for remote sensing image processing
in general and for high spatial resolution images in particular. OTB is
distributed under a free software license CeCILL (similar to GNU GPL) to
encourage contribution from users and to promote reproducible research.
This package contains the development files needed to build your own OTB
applications.

%package -n %{name}-bin
Summary:        ORFEO Toolbox command line applications
Group:          System/Libraries
Requires:       lib%{name}5 = %{version}
Obsoletes:      OrfeoToolbox

%description -n %{name}-bin
ORFEO Toolbox command line applications.
ORFEO Toolbox (OTB) is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program.
ORFEO Toolbox is distributed as an open source library of image
processing algorithms. OTB is based on the medical image processing library
ITK and offers particular functionalities for remote sensing image processing
in general and for high spatial resolution images in particular. OTB is
distributed under a free software license CeCILL (similar to GNU GPL) to
encourage contribution from users and to promote reproducible research.
This package contains the command line applications illustrating OTB features.

%package -n lib%{name}5
Summary:        ORFEO Toolbox shared library of image processing algorithms
Group:          System/Libraries
Obsoletes:      OrfeoToolbox

%description -n lib%{name}5
ORFEO Toolbox shared library of image processing algorithms.
ORFEO Toolbox (OTB) is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program.
ORFEO Toolbox is distributed as an open source library of image
processing algorithms. OTB is based on the medical image processing library
ITK and offers particular functionalities for remote sensing image processing
in general and for high spatial resolution images in particular. OTB is
distributed under a free software license CeCILL (similar to GNU GPL) to
encourage contribution from users and to promote reproducible research.
This package contains the shared libraries required by Monteverdi,
Monteverdi2 and the OTB applications.


%package -n %{name}-qt
Summary:        ORFEO Toolbox graphical user interface applications
Group:          System/Libraries
Requires:       lib%{name}5 = %{version}
Obsoletes:      OrfeoToolbox

%description -n %{name}-qt
ORFEO Toolbox graphical user interface applications.
ORFEO Toolbox (OTB) is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program.
ORFEO Toolbox is distributed as an open source library of image
processing algorithms. OTB is based on the medical image processing library
ITK and offers particular functionalities for remote sensing image processing
in general and for high spatial resolution images in particular. OTB is
distributed under a free software license CeCILL (similar to GNU GPL) to
encourage contribution from users and to promote reproducible research.
This package contains the GUI tools illustrating OTB features (using plugins
provided by otb package).


%package -n python-%{name}
Summary:        ORFEO Toolbox Python API for applications
Group:          System/Libraries
Requires:       lib%{name}5 = %{version}
Obsoletes:      OrfeoToolbox

%description -n python-%{name}
ORFEO Toolbox Python API for applications.
ORFEO Toolbox (OTB) is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program.
ORFEO Toolbox is distributed as an open source library of image
processing algorithms. OTB is based on the medical image processing library
ITK and offers particular functionalities for remote sensing image processing
in general and for high spatial resolution images in particular. OTB is
distributed under a free software license CeCILL (similar to GNU GPL) to
encourage contribution from users and to promote reproducible research.
This package contains the Python API for applications provided by the
otb package.


%prep
%setup -q -n %{tarname}-%{version}

%build
cd ..
mkdir temp
cd temp
cmake  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_EXAMPLES:BOOL=OFF \
       -DBUILD_TESTING:BOOL=OFF \
       -DOTB_USE_6S:BOOL=ON \
       -DOTB_USE_CURL:BOOL=ON \
       -DOTB_USE_LIBKML:BOOL=OFF \
       -DOTB_USE_LIBSVM:BOOL=ON \
       -DOTB_USE_MAPNIK:BOOL=OFF \
       -DOTB_USE_MUPARSER:BOOL=ON \
       -DOTB_USE_MUPARSERX:BOOL=ON \
       -DOTB_USE_OPENCV:BOOL=ON \
       -DOTB_USE_OPENJPEG:BOOL=OFF \
       -DOTB_USE_QT4:BOOL=ON \
       -DOTB_USE_SIFTFAST:BOOL=ON \
       -DOTB_WRAP_JAVA:BOOL=OFF \
       -DOTB_WRAP_PYTHON:BOOL=ON \
       -DOTB_INSTALL_LIBRARY_DIR:STRING=%{_lib} \
       -DOTB_INSTALL_PYTHON_DIR:STRING=%{_lib}/otb/python \
       -DOTB_INSTALL_APP_DIR:STRING=%{_lib}/otb/applications \
       -DCMAKE_BUILD_TYPE:STRING=Release ../%{tarname}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}

# install -d %{buildroot}%{_sysconfdir}/ld.so.conf.d
# LDCONFIG_FILE=%{buildroot}%{_sysconfdir}/ld.so.conf.d/otb.conf
# %if "%{_lib}" == "lib64"
# cat > "$LDCONFIG_FILE" <<EOF
# # Orfeo Toolbox related search paths
# /usr/lib64/otb
# EOF
# %else
# cat > "$LDCONFIG_FILE" <<EOF
# # Orfeo Toolbox related search paths
# /usr/lib/otb
# EOF
# %endif

# %if "%{_lib}" == "lib64"
# mkdir -p %{buildroot}/usr/lib64
# mv %{buildroot}/usr/lib/* %{buildroot}/usr/lib64/
# %endif

rm -rf %{buildroot}/usr/share/doc
rm -rf %{buildroot}/usr/lib/debug

%fdupes %{buildroot}


%clean
rm -rf %{buildroot}

%post -n lib%{name}5 -p /sbin/ldconfig

%postun -n lib%{name}5 -p /sbin/ldconfig

%files -n %{name}-bin
%defattr(644,root,root,755)
%{_bindir}/otbcli_*
%{_bindir}/otbcli

%files -n %{name}-qt
%defattr(644,root,root,755)
%{_bindir}/otbgui_*
%{_bindir}/otbgui

%files -n lib%{name}5
%defattr(644,root,root,755)
# %config %{_sysconfdir}/ld.so.conf.d/otb.conf
%dir %{_libdir}/otb/
%{_libdir}/*.so.*
%{_bindir}/otbTestDriver
%{_bindir}/otbApplicationLauncherCommandLine
%{_bindir}/otbApplicationLauncherQt
%dir %{_libdir}/otb/applications/
%{_libdir}/otb/applications/otbapp_*.so

%files -n python-%{name}
%defattr(644,root,root,755)
%dir %{_libdir}/otb/python/
%{_libdir}/otb/python/*

%files devel
%defattr(-,root,root,-)
%{_includedir}/OTB-5.2/
%{_libdir}/lib*.so
%{_libdir}/cmake/

%changelog
