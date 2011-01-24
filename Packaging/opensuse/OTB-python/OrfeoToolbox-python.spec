#
# spec file for package OrfeoToolbox
#

%if %{?pyver:0}%{!?pyver:1}
    %if 0%{?suse_version} > 1130
    %define pyver 2.7
    %endif
    %if 0%{?suse_version} == 1110 || 0%{?suse_version} == 1120 || 0%{?suse_version} == 1130
    %define pyver 2.6
    %endif
%endif

# we have multilib triage
%if "%{_lib}" == "lib"
%define cpuarch 32
%else
%define cpuarch 64
%endif

# norootforbuild

Name:           OrfeoToolbox-python
Version:        3.8.0
Release:        1
Summary:        The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
# BuildArch:      noarch

BuildRequires:  cmake libgdal-devel libgeotiff-devel gettext-runtime gettext-tools freeglut-devel libpng-devel
BuildRequires:	gcc-c++ gcc
BuildRequires:  fdupes libOpenThreads-devel boost-devel fltk fltk-devel CableSwig CableSwig-devel swig 
BuildRequires:  OrfeoToolbox-devel OrfeoToolbox
BuildRequires:	python-devel >= %{pyver}

%description
Python bindings for the OrfeoToolbox library

%prep
%setup -q


%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_TESTING:BOOL=OFF \
       -DOTB_DIR:PATH=/usr/%{_lib} \
       -DWRAP_ITK_PYTHON:BOOL=On \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DPYTHON_INCLUDE_DIR:PATH=%{py_incdir} \
       -DPYTHON_LIBRARY:PATH=%{py_libdir} \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 


%install
cd ../temp
make install DESTDIR=%{buildroot}
%if "%{_lib}" == "lib64"  
mkdir %{buildroot}/usr/%{_lib}
mv %{buildroot}/usr/lib/otb-wrapping %{buildroot}/usr/%{_lib}/
%endif
%fdupes %{buildroot}


%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_libdir}/otb-wrapping/

%changelog
