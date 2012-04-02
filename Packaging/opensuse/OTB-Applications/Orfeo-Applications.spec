# spec file for package Orfeo-Applications

# norootforbuild

Name:           Orfeo-Applications
Version:        3.12.0
Release:        1
Summary:        Applications based on OrfeoToolbox for remote sensing image processing
Group:          Development/Libraries
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake libgdal-devel libgeotiff-devel gcc-c++ gcc gettext-runtime gettext-tools freeglut-devel libpng-devel libqt4-devel
BuildRequires:  fdupes libOpenThreads-devel boost-devel OrfeoToolbox-devel
BuildRequires:	fltk-devel
BuildRequires:	fltk


%description
The %{name} is a set of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program

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
       -DOTB_USE_QGIS:BOOL=OFF \
       -DOTB_USE_QT:BOOL=ON \
       -DOTB_DIR:PATH=%{_libdir}/otb \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

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
%{_libdir}/otb/*


%changelog

