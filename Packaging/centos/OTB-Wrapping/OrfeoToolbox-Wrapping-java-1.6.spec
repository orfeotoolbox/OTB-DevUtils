# spec file for package OrfeoToolbox-Wrapping (Java and Python bindings)

# norootforbuild

Name:          OrfeoToolbox-Wrapping
Version:       1.8.0
Release:       1+java6
Summary:       The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:         Development/Libraries
License:       Cecill
URL:           http://www.orfeo-toolbox.org
Source0:       %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-build

BuildRequires: cmake >= 2.8.6 gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel
BuildRequires: libpng-devel boost-devel fltk-devel fltk-fluid CableSwig-devel
BuildRequires: swig >= 1.3.40 python26 python26-devel jdk >= 1.6.0
BuildRequires: OrfeoToolbox-devel OrfeoToolbox

Requires:      OrfeoToolbox = 3.12.0


%description
Java and Python bindings for the OrfeoToolbox library

The %{name} is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program


%package java
Summary:        Java bindings for The Orfeo Toolbox library
Group:          Development/Libraries
License:        Cecill
Requires:       jdk >= 1.6.0 OrfeoToolbox = 3.12.0


%description java
Java bindings for the Orfeo Toolbox library


%package python
Summary:        Python bindings for The Orfeo Toolbox library
Group:          Development/Libraries
License:        Cecill
Requires:       python26 OrfeoToolbox = 3.12.0


%description python
Python bindings for the OrfeoToolbox library


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
      -DOTB_DIR:PATH=/usr/lib/otb \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DWRAP_ITK_JAVA:BOOL=ON \
      -DJava_JAR_EXECUTABLE:FILEPATH=/usr/java/jdk1.6.0_25/bin/jar \
      -DJava_JAVAC_EXECUTABLE:FILEPATH=/usr/java/jdk1.6.0_25/bin/javac \
      -DJava_JAVA_EXECUTABLE:FILEPATH=/usr/java/jdk1.6.0_25/bin/java \
      -DJava_JAVAH_EXECUTABLE:FILEPATH=/usr/java/jdk1.6.0_25/bin/javah \
      -DJava_JAVADOC_EXECUTABLE:FILEPATH=/usr/java/jdk1.6.0_25/bin/javadoc \
      -DWRAP_ITK_PYTHON:BOOL=ON \
      -DCMAKE_SKIP_RPATH:BOOL=ON \
      -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}


%clean
rm -rf %{buildroot}
rm -rf ../temp


%post python
LDCONFIG_FILE=/etc/ld.so.conf.d/otb-wrapping-python.conf
if [ ! -f "$LDCONFIG_FILE" ] ; then
	cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox bindings for Python related search paths
/usr/lib/otb-wrapping/lib
EOF
fi
/sbin/ldconfig


%post java
LDCONFIG_FILE=/etc/ld.so.conf.d/otb-wrapping-java.conf
if [ ! -f "$LDCONFIG_FILE" ] ; then
	cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox bindings for Java related search paths
/usr/lib/otb-wrapping/lib
EOF
fi
/sbin/ldconfig


%postun python
LDCONFIG_FILE=/etc/ld.so.conf.d/otb-wrapping-python.conf
if [ -f "$LDCONFIG_FILE" ] ; then
	rm -f "$LDCONFIG_FILE"
fi
/sbin/ldconfig


%postun java
LDCONFIG_FILE=/etc/ld.so.conf.d/otb-wrapping-java.conf
if [ -f "$LDCONFIG_FILE" ] ; then
	rm -f "$LDCONFIG_FILE"
fi
/sbin/ldconfig


%files
%defattr(-,root,root,-)
%{_libdir}/otb-wrapping/*.cmake
%{_libdir}/otb-wrapping/Configuration/*.cmake
%{_libdir}/otb-wrapping/Configuration/Languages/CMakeLists.txt
%{_libdir}/otb-wrapping/Configuration/Languages/GccXML/
%{_libdir}/otb-wrapping/Configuration/Languages/itk.i
%{_libdir}/otb-wrapping/Configuration/Languages/SwigInterface/
%{_libdir}/otb-wrapping/Configuration/Typedefs/itk*
%{_libdir}/otb-wrapping/Configuration/Typedefs/otb*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_ITK*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkA*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkB*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkC*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkD*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkE*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkF*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkG*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkH*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkI*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkJ*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkK*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkL*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkM*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkN*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkO*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkPa*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkPe*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkPl*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkPo*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkPD*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkQ*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkR*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkS*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkT*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkV*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkW*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkX*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkZ*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_otb*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_v*


%files java
%defattr(-,root,root,-)
%{_libdir}/otb-wrapping/lib/*.jar
%{_libdir}/otb-wrapping/lib/*Java.so
%{_libdir}/otb-wrapping/Configuration/Languages/Java/
%{_libdir}/otb-wrapping/Configuration/Typedefs/java/
%{_libdir}/otb-wrapping/Configuration/Typedefs/ITKJava*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_java*


%files python
%defattr(-,root,root,-)
%{_libdir}/otb-wrapping/Python/
%{_libdir}/otb-wrapping/lib/*.py
%{_libdir}/otb-wrapping/lib/*.pyc
%{_libdir}/otb-wrapping/lib/*.pyo
%{_libdir}/otb-wrapping/lib/*Python.so
%{_libdir}/otb-wrapping/Configuration/Languages/Python/
%{_libdir}/otb-wrapping/Configuration/Typedefs/python/
%{_libdir}/otb-wrapping/Configuration/Typedefs/ITKPy*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_itkPy*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_py*
%{_libdir}/otb-wrapping/Configuration/Typedefs/wrap_Py*


%changelog
* Wed Mar 21 2012 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.8.0-1+java6
- Packaging OTB Wrapping 1.8 for CentOS 5.5

* Fri Dec 09 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.7.0-0+java6
- Packaging OTB Wrapping 1.7 for CentOS 5.5

* Wed Jul 06 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.6.0-0+java6
- Packaging OTB Wrapping 1.6 for CentOS 5.5

* Mon May 06 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.4.0-4-java6
- CentOS package build against Sun JDK 1.6.0-25

* Mon May 02 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 1.4.0-2
- Java wrapping added
- Packaging for CentOS 5.5

* Thu Dec 10 2010 Angelos Tzotsos <tzotsos@gmail.com> - 1.4.0-1
- Initial build
- Packaging for OpenSuse
