# spec file for package OrfeoToolbox

# norootforbuild

Name:           OrfeoToolbox
Version:        3.10.0
Release:        2
Summary:        The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel libpng-devel
BuildRequires:  boost-devel fltk-devel fltk-fluid uuid-devel proj-devel expat-devel
BuildRequires:  mapnik-devel libicu-devel libtool libtool-ltdl-devel


%description
The %{name} is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program


%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}
Requires:       cmake gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel libpng-devel
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
      -DOTB_USE_GETTEXT:BOOL=OFF \
      -DOTB_USE_CURL:BOOL=ON \
      -DOTB_USE_MAPNIK:BOOL=ON \
      -DOTB_USE_EXTERNAL_EXPAT:BOOL=ON \
      -DOTB_USE_EXTERNAL_FLTK:BOOL=ON \
      -DOTB_USE_EXTERNAL_BOOST:BOOL=ON \
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
/usr/lib/otb
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


%files devel
%defattr(-,root,root,-)
%{_includedir}/otb/
%{_libdir}/otb/lib*.so
%{_libdir}/otb/*.cmake


%changelog
* Tue Jul 05 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-2
- Packaging OTB 3.10 for CentOS 5.5

* Mon May 02 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.8.0-2
- Packaging OTB 3.8 for CentOS 5.5

* Thu Dec 10 2010 Angelos Tzotsos <tzotsos@gmail.com> - 3.8.0-1
- Initial build
- Packaging for OpenSuse
