#
# spec file for package OTB
#
# Copyright (c) 2014 Angelos Tzotsos <tzotsos@opensuse.org>.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the OTB package itself (unless the
# license for the OTB package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/

# norootforbuild

Name:           OTB
Version:        4.0.0rc1
Release:        1
Summary:        The Orfeo Toolbox (OTB) is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        CECILL-2.0
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-4.0-rc1.tgz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:	cmake >= 2.8.0
BuildRequires:  libgdal-devel 
BuildRequires:  libgeotiff-devel 
BuildRequires:  gcc-c++ 
BuildRequires:  gcc 
BuildRequires:  gettext-runtime 
BuildRequires:	gettext-tools 
BuildRequires:  freeglut-devel 
BuildRequires:  libpng-devel 
BuildRequires:  uuid-devel 
BuildRequires:  libproj-devel 
BuildRequires:	libexpat-devel 
BuildRequires:  libicu-devel 
BuildRequires:  libtool 
BuildRequires:  libltdl7 
BuildRequires:  swig 
BuildRequires:  python-devel 
BuildRequires:  python 
BuildRequires:  python-base
BuildRequires:  fdupes 
BuildRequires:  libOpenThreads-devel 
BuildRequires:  boost-devel
BuildRequires:	curl 
BuildRequires:  libqt4-devel 
BuildRequires:  fftw3-devel
BuildRequires:	fftw3-threads-devel
BuildRequires:	fltk-devel
Requires:       gdal 
Requires:       expat 
Requires:       libgdal1 
Requires:       libgeotiff 
Requires:       libpng 
Requires:       python


%description
The %{name} is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program

%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}
Requires: 	cmake 
Requires:       gcc-c++ 
Requires:       gcc 
Requires:       freeglut-devel 
Requires:       libgeotiff-devel 
Requires:       libgdal-devel
Requires:       libpng-devel 
Requires:       boost-devel 
Requires:       fftw3-devel
Requires:	fftw3-threads-devel
Requires:	fltk-devel

%description    devel
Development files for the %{name} library. The %{name} is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program


%prep
%setup -q -n %{name}-4.0-rc1

%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_EXAMPLES:BOOL=OFF \
       -DBUILD_TESTING:BOOL=OFF \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_APPLICATIONS:BOOL=ON \
       -DOTB_USE_GETTEXT:BOOL=OFF \
       -DOTB_USE_CURL:BOOL=ON \
       -DOTB_USE_FFTW:BOOL=ON \
       -DOTB_USE_MAPNIK:BOOL=OFF \
       -DOTB_USE_EXTERNAL_EXPAT:BOOL=ON \
       -DOTB_USE_EXTERNAL_FLTK:BOOL=ON \
       -DOTB_USE_EXTERNAL_BOOST:BOOL=ON \
       -DOTB_USE_EXTERNAL_GDAL:BOOL=ON \
       -DOTB_USE_EXTERNAL_ITK:BOOL=OFF \
       -DOTB_WRAP_QT:BOOL=ON \
       -DOTB_WRAP_PYTHON:BOOL=ON \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DOTB_INSTALL_LIB_DIR:STRING=%{_lib}/otb \
       -DOTB_INSTALL_APP_DIR:STRING=%{_lib}/otb/applications \
       -DOTB_INSTALL_PYTHON_DIR:STRING=%{_lib}/otb/python \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-4.0-rc1/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}
install -d %{buildroot}%{_sysconfdir}/ld.so.conf.d
LDCONFIG_FILE=%{buildroot}%{_sysconfdir}/ld.so.conf.d/otb.conf
%if "%{_lib}" == "lib64"
cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox related search paths
/usr/lib64/otb
EOF
%else
cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox related search paths
/usr/lib/otb
EOF
%endif

%if "%{_lib}" == "lib64"
mkdir -p %{buildroot}/usr/lib64
mv %{buildroot}/usr/lib/* %{buildroot}/usr/lib64/
%endif

rm -rf %{buildroot}/usr/share/doc
rm -rf %{buildroot}/usr/lib/debug

%fdupes %{buildroot}%{_includedir}/otb


%clean
rm -rf %{buildroot}

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%files
%defattr(-,root,root,-)
%config %{_sysconfdir}/ld.so.conf.d/otb.conf
%{_bindir}/*
#%{_libdir}/lib*.so.*
%dir %{_libdir}/otb/
%{_libdir}/otb/lib*.so.*
%dir %{_libdir}/otb/applications/
%dir %{_libdir}/otb/python/
%{_libdir}/otb/applications/*
%{_libdir}/otb/python/*

%files devel
%defattr(-,root,root,-)
%{_includedir}/otb/
%{_libdir}/otb/lib*.so
%{_libdir}/cmake/
#%{_libdir}/lib*.so
%{_libdir}/otb/*.cmake
%{_libdir}/otb/cmakemodules/ 

%changelog
