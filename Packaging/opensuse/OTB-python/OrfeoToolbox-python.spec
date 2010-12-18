#
# spec file for package OrfeoToolbox
#

# norootforbuild

Name:           OrfeoToolbox-python
Version:        3.6.0
Release:        1
Summary:        The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
# BuildArch:      noarch

BuildRequires:  cmake libgdal-devel libgeotiff-devel gettext-runtime gettext-tools freeglut-devel libpng-devel
%if %suse_version >= 1130
BuildRequires:	gcc43-c++ gcc43 libgcc43 libstdc++43-devel
%else
BuildRequires:	gcc-c++ gcc libgcc
%endif
#Requires:       libgdal1 libgeotiff freeglut libpng14
BuildRequires:  fdupes libOpenThreads-devel boost-devel fltk fltk-devel python-devel CableSwig CableSwig-devel swig 
BuildRequires:  OrfeoToolbox-devel OrfeoToolbox

%description
Python bindings for the OrfeoToolbox library

%prep
%setup -q


%build
%if %suse_version >= 1130
export CC=gcc-4.3
export CXX=g++-4.3
export CXXFLAGS="%{optflags}"
export CFLAGS="$CXXFLAGS"
%endif
cd ..
mkdir temp
cd temp
cmake  -DBUILD_TESTING:BOOL=OFF \
       -DOTB_DIR:PATH=/usr/%{_lib} \
       -DWRAP_ITK_PYTHON:BOOL=On \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}
%fdupes %{buildroot}


%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)

%changelog
* Thu Dec 11 2010 Angelos Tzotsos <tzotsos@gmail.com> - 3.6.0-1
- Initial build
