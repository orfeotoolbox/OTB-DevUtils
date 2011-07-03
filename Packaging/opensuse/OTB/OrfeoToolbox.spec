#
# spec file for package OrfeoToolbox
#

# norootforbuild

Name:           OrfeoToolbox
Version:        3.10.0
Release:        1
Summary:        The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
# BuildArch:      noarch

BuildRequires:  cmake libgdal-devel libgeotiff-devel gcc-c++ gcc gettext-runtime gettext-tools freeglut-devel libpng-devel
#Requires:       libgdal1 libgeotiff freeglut libpng14
BuildRequires:  fdupes libOpenThreads-devel boost-devel fltk fltk-devel

%description
The %{name} is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program

%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}
#Requires: 	libgeotiff-devel libgdal-devel freeglut libpng14-devel

%description    devel
Development files for the %{name} library. The %{name} is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program


%prep
%setup -q


%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_EXAMPLES:BOOL=OFF \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_TESTING:BOOL=OFF \
       -DOTB_USE_EXTERNAL_FLTK:BOOL=ON \
       -DOTB_INSTALL_LIB_DIR:STRING=/%{_lib} \
       -DITK_INSTALL_LIB_DIR:STRING=/%{_lib} \
       -DOTB_USE_VISU_GUI:BOOL=ON \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}
mv %{buildroot}/usr/lib/otb/*.cmake %{buildroot}%{_libdir}/
%fdupes %{buildroot}%{_includedir}/otb


%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_libdir}/lib*.so.*

%files devel
%defattr(-,root,root,-)
%{_includedir}/otb/
%{_libdir}/lib*.so
%{_libdir}/*.cmake 

%changelog
