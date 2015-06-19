# spec file for gdal openjpeg plugin
#based on otb wiki page - http://wiki.orfeo-toolbox.org/index.php/JPEG2000_with_GDAL_OpenJpeg_plugin#External_driver
# norootforbuild
%define name gdal-openjpeg
%define sname gdal
#keep same version of gdal
%define version 1.10.1
%define _prefix /usr
%define _sharedir %{_prefix}/share

Name:  %{name}
Version:  %{version}
#keep same rev as in gdal
Release:  2%{?dist}
Summary:  OpenJPEG2000 plugin for gdal
Group:  Development/Libraries
License:  MIT
URL:  http://www.orfeo-toolbox.org
Source0:  http://download.osgeo.org/gdal/%{version}/gdal-%{version}.tar.gz
Source1:  gdal-config-64
BuildRequires:  gcc-c++ 
BuildRequires:  gcc
BuildRequires:  openjpeg2-devel
BuildRequires:  gdal-devel
Requires:  gdal

%description
This package provides openjpeg plugin for gdal

%prep
%setup -q -n %{sname}-%{version}
cp -a %{SOURCE1} .

%build
g++ -fPIC -g -Wall frmts/openjpeg/openjpegdataset.cpp -shared -o gdal_JP2OpenJPEG.so \
    -I%{_includedir}/gdal -I%{_includedir} -Lfrmts/openjpeg/ -lgdal -L%{_libdir} -lopenjp2

%install
mkdir -p %{buildroot}%{_libdir}/gdalplugins
mkdir -p %{buildroot}%{_bindir}/
install gdal_JP2OpenJPEG.so %{buildroot}%{_libdir}/gdalplugins
install gdal-config* %{buildroot}%{_bindir}/
%clean
rm -rf %{buildroot}
rm -rf *.so

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_libdir}/gdalplugins/*.so*
%{_bindir}/gdal-config*

%dir %{_libdir}/gdalplugins


%changelog
* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 1.0-1
- test package for gdal openjpeg plugin
