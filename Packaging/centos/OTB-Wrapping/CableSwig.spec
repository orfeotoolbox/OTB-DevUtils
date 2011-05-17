# Spec file for package CableSwig

# norootforbuild

Name:           CableSwig
Version:        3.20.0
Release:        2
Summary:        CableSwig is used to create wrappers to interpreted languages such as Tcl and Python
Group:          Development/Libraries
License:        Apache 2.0
URL:            http://www.itk.org/ITK/resources/CableSwig.html
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake gcc-c++ gcc


%description
CableSwig is used to create wrappers to interpreted languages such as Tcl and Python


%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}


%description    devel
Development files for the %{name}


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
cmake  -DCMAKE_INSTALL_PREFIX:PATH=/usr ../%{name}-%{version}/

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
%{_bindir}/*


%files devel
%defattr(-,root,root,-)
%dir /usr/lib/CableSwig
/usr/lib/CableSwig/*


%changelog
* Thu May 6 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.20.0-2
- CentOS 5.5 package

* Thu Dec 10 2010 Angelos Tzotsos <tzotsos@gmail.com> - 3.20.0-1
- Initial build
