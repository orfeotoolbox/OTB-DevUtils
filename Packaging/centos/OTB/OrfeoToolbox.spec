# spec file for package OrfeoToolbox

# norootforbuild

Name:          OrfeoToolbox
Version:       3.16.0
Release:       1
Summary:       The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:         Development/Libraries
License:       Cecill
URL:           http://www.orfeo-toolbox.org
Source0:       %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-build

BuildRequires: cmake >= 2.8.6 gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel
BuildRequires: libpng-devel boost-devel fltk-devel fltk-fluid uuid-devel proj-devel
BuildRequires: expat-devel libicu-devel libtool libtool-ltdl-devel
BuildRequires: swig >= 1.3.40 python python-devel qt-devel

Requires:      gdal fltk expat boost python


%description
The %{name} is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program


%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}
Requires:       cmake >= 2.8.6 gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel libpng-devel
Requires:       boost-devel fltk-devel fltk-fluid


%description    devel
Development files for the %{name} library. The %{name} is a library of
image processing algorithms developed by CNES in the frame of the
ORFEO Accompaniment Program


%prep
%setup -q


%build
cd ..
if [ -d temp ] ; then
        rm -rf temp/*
else
        mkdir temp
fi
cd temp
cmake -DBUILD_EXAMPLES:BOOL=OFF \
      -DBUILD_TESTING:BOOL=OFF \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DBUILD_APPLICATIONS:BOOL=ON \
      -DOTB_USE_GETTEXT:BOOL=OFF \
      -DOTB_USE_CURL:BOOL=ON \
      -DOTB_USE_MAPNIK:BOOL=OFF \
      -DOTB_USE_EXTERNAL_EXPAT:BOOL=ON \
      -DOTB_USE_EXTERNAL_FLTK:BOOL=ON \
      -DOTB_USE_EXTERNAL_BOOST:BOOL=ON \
      -DBoost_NO_BOOST_CMAKE:BOOL=ON \
      -DOTB_USE_EXTERNAL_GDAL:BOOL=ON \
      -DOTB_WRAP_QT:BOOL=ON \
      -DOTB_WRAP_PYTHON:BOOL=ON \
      -DOTB_INSTALL_LIB_DIR:PATH=%{_lib}/otb \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DCMAKE_SKIP_RPATH:BOOL=ON \
      -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/
make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}


%clean
rm -rf %{buildroot}
rm -rf ../temp


%post
LDCONFIG_FILE=/etc/ld.so.conf.d/otb.conf
if [ ! -f "$LDCONFIG_FILE" ] ; then
        cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox related search paths
%{_libdir}/otb
%{_libdir}/otb/applications
%{_libdir}/otb/python
EOF
fi
/sbin/ldconfig


%postun
LDCONFIG_FILE=/etc/ld.so.conf.d/otb.conf
if [ -f "$LDCONFIG_FILE" ] ; then
        rm -f "$LDCONFIG_FILE"
fi
/sbin/ldconfig


%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_libdir}/otb/lib*.so.*
%{_libdir}/otb/applications/*
%{_libdir}/otb/python/*


%files devel
%defattr(-,root,root,-)
%{_includedir}/otb/
%{_libdir}/otb/lib*.so
%{_libdir}/otb/*.cmake
%{_libdir}/otb/cmakemodules/*.cmake

%changelog
* Thu Feb 01 2013 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.16.0-1
- Packaging OTB 3.16 for CentOS 6.3
- Updated dependencies
- Boost_NO_BOOST_CMAKE and OTB_INSTALL_LIB_DIR added on CMake command line
- otb/cmakemodules/*.cmake files added to installed files
- Mapnik disabled
- Default Python version used

* Wed Mar 21 2012 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.12.0-1
- Packaging OTB 3.12 for CentOS 5.5

* Fri Dec 09 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.11.0-1
- Packaging OTB 3.11 for CentOS 5.5

* Thu Jul 07 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-3
- Dependencies improved

* Tue Jul 05 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-2
- Packaging OTB 3.10 for CentOS 5.5

* Mon May 02 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.8.0-2
- Packaging OTB 3.8 for CentOS 5.5

* Thu Dec 10 2010 Angelos Tzotsos <tzotsos@gmail.com> - 3.8.0-1
- Initial build
- Packaging for OpenSuse
