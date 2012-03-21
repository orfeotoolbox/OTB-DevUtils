# spec file for package Monteverdi (Image processing workshop)

# norootforbuild

Name:           Monteverdi
Version:        1.10.0
Release:        1
Summary:        Application based on OrfeoToolbox for remote sensing image processing
Group:          Applications/Image
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires: cmake gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel libpng-devel
BuildRequires: boost-devel fltk-devel fltk-fluid gettext-devel
BuildRequires: OrfeoToolbox-devel OrfeoToolbox

Requires:      OrfeoToolbox = 3.12.0


%description
Monteverdi is an image processing workshop based on the Orfeo Toolbox
(OTB) library. It takes advantage of the streaming and multi-threading
capabilities of the OTB pipeline. It also uses cool features as
processing on demand and automagic file format I/O. Monteverdi is
distributed under a free software license CeCILL (similar to GNU GPL)
to encourage contribution from users and to promote reproducible
research.

Orfeo Toolbox is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program.


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
cmake -DBUILD_TESTING:BOOL=OFF \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DCMAKE_SKIP_RPATH:BOOL=ON \
      -DOTB_DIR:PATH=%{_libdir} \
      -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}


%clean
rm -rf %{buildroot}
rm -rf ../temp


%post -p /sbin/ldconfig


%postun -p /sbin/ldconfig


%files
%defattr(-,root,root,-)
%{_bindir}/monteverdi
%{_libdir}/otb/lib*.so
%{_datadir}/pixmaps/monteverdi.*
%{_datadir}/applications/monteverdi.desktop


%changelog
* Wed Mar 21 2012 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.10.0-1
- Packaging Monteverdi 1.10 for CentOS 5.5

* Fri Dec 09 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.9.0-0
- Packaging Monteverdi 1.9 for CentOS 5.5

* Wed Jul 06 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.8.0-0
- Packaging Monteverdi 1.8 for CentOS 5.5

* Fri Jun 24 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.6.1-1
- 1.6.1 = 1.6.0 + pixmaps and desktop entry files
- Initial build
- Packaging for CentOS 5.5
