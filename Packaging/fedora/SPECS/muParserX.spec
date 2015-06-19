#name of library as it is
Name:           muParserX
Version:        3.0.5
Release:        1%{?dist}
Summary:        A C++ Library for Parsing Expressions with Strings, Complex Numbers, Vectors, Matrices and more
Group:          System Environment/Libraries
#TODO: Which version?
License:        BSD-2-Clause
URL:            https://github.com/beltoforion/muparserx/%{name}-%{version}
Source0:        https://github.com/beltoforion/muparserx/%{name}-%{version}.zip
Patch0:         %{name}-3.0.5-cmakelists.patch
BuildRequires: cmake
#BuildRequires: help2man

%description
A C++ Library for Parsing Expressions with
Strings, Complex Numbers, Vectors, Matrices and more

%package	    devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
This provides all includes and libraries required for
development of %{name} library

%package	    doc
Summary:        Documentation for %{name}
Group:          Documentation
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description doc
This provides documentation for %{name} library

%prep
#---
# Notes for debugging:
# -D on setup = Do not delete the directory before unpacking.
# -T on setup = Disable the automatic unpacking of the archives.
#---
# %setup -q -D -T
%setup -q -D

%patch0 -p1


mkdir -p %{_target_platform}
pushd %{_target_platform}
%cmake .. -DCMAKE_BUILD_TYPE:STRING="Release"
popd

make %{?_smp_mflags} -C %{_target_platform}

%install
%make_install -C %{_target_platform}

%post -n muParserX -p /sbin/ldconfig

%postun -n muParserX -p /sbin/ldconfig

%files
%{_libdir}/libmuparserx.so

%files devel
%{_includedir}/*.h
%{_libdir}/libmuparserx.so

%files doc
%doc License.txt
%doc Readme.txt

%changelog
* Wed Apr 22 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 3.5.0-1
- Initial package
