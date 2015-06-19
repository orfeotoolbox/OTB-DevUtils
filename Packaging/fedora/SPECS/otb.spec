# spec file for package OrfeoToolbox
# norootforbuild

%global _version_major 5
%global _version_minor 0
%global _version_release 0
%global _uname OTB
%global _short_name %{_uname}-%{_version_major}.%{_version_minor}


Name: otb
# OrfeoToolbox
Version:       %{_version_major}.%{_version_minor}.%{_version_release}
Release:       1%{?dist}
Summary:       The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:	       System Environment/Libraries
# The entire source code is CeCILL except Utilities/*
License:       CeCILL
URL:	       http://www.orfeo-toolbox.org
Source0:       http://orfeo-toolbox.org/packages/%{_uname}-%{version}.tgz
#File will be merged with upstream - http://bugs.orfeo-toolbox.org/view.php?id=987
Source1:       README.txt
Source2:       otb.conf
Patch0:        %{_uname}-4.5.0-docinstall.patch
#Patch0:	       %{_uname}-4.2.1-6S_main.patch
#Patch1:	       %{_uname}-4.2.1-dm_CMakeLists.patch
#Patch2:	       %{_uname}-4.2.1-rpmlint_fsfaddr.patch

BuildRequires: cmake
BuildRequires: gdal-devel >= 1.11.2
BuildRequires: libgeotiff-devel
BuildRequires: libpng-devel
BuildRequires: boost-devel
BuildRequires: expat-devel
BuildRequires: curl-devel
BuildRequires: tinyxml-devel
BuildRequires: muParser-devel
BuildRequires: muParserX-devel >= 3.0.5
BuildRequires: OpenThreads-devel
BuildRequires: libjpeg-turbo-devel
BuildRequires: openjpeg2-devel >= 2.1.0-4
BuildRequires: openjpeg2-tools >= 2.1.0-4
BuildRequires: InsightToolkit-devel >= 4.7.1
BuildRequires: InsightToolkit-vtk  >= 4.7.1
BuildRequires: ossim-devel >= 1.8.18
### test package to install only jpeg plugin
###BuildRequires: gdal-openjpeg
#for generating man pages from help
BuildRequires: help2man
#(version in Fedora 20 is 4.4)
BuildRequires: opencv-devel
BuildRequires:  zlib-devel
BuildRequires:  qt-devel
##build requires from itk
BuildRequires:  gdcm-devel
BuildRequires:  vxl-devel
BuildRequires:  python2-devel


%description
The %{name} is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program

# %package        qt
# Summary:	Qt Widget wrapper for %{name}
# Group:		Development/Libraries
# Requires:	%{name} = %{version}

# %description    qt
# Qt Widget wrapper for the %{name} library.

# The %{name} is a library of image processing algorithms developed by
# CNES in the frame of the ORFEO Accompaniment Program

%package        devel
Summary:	Development files for %{name}
Group:		Development/Libraries
Requires:	%{name} = %{version}

%description    devel
Development files for the %{name} library.

The %{name} is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program

%package        doc
Summary:	Documentation files for %{name}
Group:		Documentation
Requires:	%{name} = %{version}
BuildArch:	noarch

%description doc
This package provides additional documentation for %{name}

%package        python
Summary:	Python bindings for %{name}
Group:		Development/Libraries
Requires:	%{name} = %{version}
BuildRequires:	swig >= 1.3.40 python
BuildRequires:	python2-devel

%description python
This package provides python bindings for %{name}

%prep
%setup -q -n %{_uname}-%{version} -D

cp -a %{SOURCE1} .

#ld.so.conf.d/otb.conf
cp -a %{SOURCE2} .

#prep otb.conf
sed -i 's,prefix,%{_libdir},g' otb.conf

%patch0 -p1
#%patch1 -p1
#%patch2 -p1

for lic in `ls Copyright/*.txt` ; do \
    sed -i 's/\r$//' $lic; \
done

#otb6S  otbedison  otbossimplugins  otbsvm  otbsiffast  otbopenjpeg ITK
#for tparty in BGL otbossim otbmuparser otbopenthreads otbmsinttypes otbexpat tinyXMLlib; do \
#    rm -fr Utilities/${tparty}; \
#done

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}

%cmake \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DOTB_USE_CURL:BOOL=ON \
    -DOTB_USE_OPENCV:BOOL=ON \
    -DOTB_USE_6S:BOOL=ON \
    -DOTB_USE_MUPARSER:BOOL=ON \
    -DOTB_USE_MUPARSERX:BOOL=ON \
    -DOTB_USE_OPENCV:BOOL=ON \
    -DOTB_USE_SIFTFAST:BOOL=ON \
    -DOTB_USE_QT4:BOOL=ON \
    -DOTB_WRAP_PYTHON:BOOL=ON \
    -DOTB_WRAP_JAVA:BOOL=OFF \
    -DOTB_USE_MAPNIK:BOOL=OFF \
    -DOTB_USE_LIBSVM:BOOL=OFF \
    -DOTB_USE_LIBKML:BOOL=OFF \
    -DOpenJPEG_DIR:PATH=%{_libdir}/openjpeg-2.1 \
    -DCMAKE_INSTALL_PREFIX:PATH=%{_prefix} \
    -DOTB_INSTALL_LIBRARY_DIR:STRING=%{_lib} \
    -DOTB_INSTALL_PYTHON_DIR:STRING=%{_lib}/otb/python \
    -DOTB_INSTALL_APP_DIR:STRING=%{_lib}/otb/applications \
    -DOTB_INSTALL_DOC_DIR:STRING=share/doc/%{_short_name} \
    -DCMAKE_SKIP_RPATH:BOOL=ON \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    %{_builddir}/%{_uname}-%{version}
popd

make %{?_smp_mflags} -C %{_target_platform}

%install
rm -rf %{buildroot}
%make_install -C %{_target_platform} DESTDIR=%{buildroot}

export PATH=$PATH:%{buildroot}%{_bindir}
export LD_LIBRARY_PATH=%{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_mandir}/man1
echo "Generating man pages"
help2man otbTestDriver --no-discard-stderr --version-string=%{version}  -o %{buildroot}%{_mandir}/man1/otbTestDriver.1 ;
for file in `ls %{buildroot}%{_bindir}/otbcli*  %{buildroot}%{_bindir}/otb*Launcher*` ; do
    help2man `basename $file` --no-discard-stderr --help-option=' ' --version-string=%{version} -o %{buildroot}%{_mandir}/man1/`basename $file`.1;
done
for file in `ls %{buildroot}%{_bindir}/otbgui*` ; do
    help2man `basename $file` --no-discard-stderr --help-option=' ' --version-string=%{version} -o %{buildroot}%{_mandir}/man1/`basename $file`.1;
done

mkdir -p %{buildroot}%{_sysconfdir}/ld.so.conf.d/
install -p -m644 otb.conf %{buildroot}%{_sysconfdir}/ld.so.conf.d/otb.conf

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_bindir}/otb*CommandLine
%{_bindir}/otbcl*
%{_bindir}/otbTestDriver
%{_libdir}/libOTB*.so*
%{_libdir}/libotb*.so*
%{_libdir}/otb/applications/otbapp_*
%{_mandir}/man1/otbcli*.1*
%{_sysconfdir}/ld.so.conf.d/otb.conf
%{_mandir}/man1/otbApplicationLauncherCommandLine.1*
%{_mandir}/man1/otbTestDriver.1*
%{_bindir}/otb*Qt
%{_bindir}/otbgu*
%{_libdir}/lib*QtWidget*.so.*
%{_mandir}/man1/otbgui*.1*
%{_mandir}/man1/otbApplicationLauncherQt.1.*
%dir %{_libdir}/otb/

%files devel
%{_includedir}/%{_short_name}
%{_libdir}/cmake/%{_short_name}

%files doc
%doc README.txt
%doc RELEASE_NOTES.txt
%doc Copyright/*.txt
%doc LICENSE

#location of python package need to be clarified for Fedora
%files python
%{_libdir}/otb/python/*
%dir %{_libdir}/otb/python/

%changelog
* Tue Jun 09 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 5.0.0-1
- update to OTB 5.0.0

* Tue Apr 28 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.5.0-1
- added patch to not install LICENSE which is included in doc

* Mon Apr 27 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.5.0-1
- update files devel, qt, doc sections for OTB 4.5

* Fri Apr 24 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.5.0-1
- update to OTB 4.5
- minimum required version added for ITK, OSSIM and GDAL
- muParserX added to dependencies

* Fri Nov 28 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.2.1-2
- updated patch names as per Fedora Guidelines(volter)
- add RELEASE_NOTES.txt in doc package
- removed pdf from SRPM and added links in a README(volter)

* Wed Nov 26 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.2.1-2
- added gdcm and vxl to build requires for OTB
- rpmlint dangerous command in postun /bin/rm fixed
- embed man page generation within and remove external source

* Tue Nov 25 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.2.1-2
- using external ITK and OSSIM
- incorrect date in changelog Thu Feb 01 2013
- incorrect date in changelog Fri Dec 10 2010
- Building package in RelWithDebInfo mode
- remove bundled libraries from Utilities when using system package

* Mon Nov 24 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.2.1-1
- moved Qt widget wrapper and otbgui* to otb-qt package
- added generate_manpages.sh for creating man pages via help2man
- moved cleanup of otb.conf to external script to silence rpmlint
- install OTB/Copyright/*.txt with documentation package
- fixed no manual page for binary from rpmlint
- use system installed openthreads

* Fri Nov 21 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.2.1-1
- initial package for Fedora
- activated OpenCV

* Wed Nov 19 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.2.1-1
- cmake option Boost_NO_BOOST_CMAKE added to fix Boost import error
- defined a version variable for ITK and use it instead of ITK-4.5
- activated curl via OTB_USE_CURL
- added muParser and tinyxml to Build-Requires
- added documentation and python package
- fixed several rpmlint warnings

* Tue Sep 30 2014 Benjamin Duplex <benjamin.duplex@c-s.fr> - 4.0.0-2
- Delete empty directories after package uninstallation

* Thu Aug 28 2014 Benjamin Duplex <benjamin.duplex@c-s.fr> - 4.0.0-1
- Packaging OTB 4.0.0 for CentOS 6.3
- Updated dependencies
- Used non-generic packages of gdal (1.10) and opendjpeg (2.0).
- Internal ITK used
- FFTWD and FFTWF disables
- Mapnik disabled
- Default Python version used

* Fri Feb 01 2013 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.16.0-1
- Packaging OTB 3.16 for CentOS 6.3
- Updated dependencies
- Boost_NO_BOOST_CMAKE and OTB_INSTALL_LIB_DIR added on CMake command line
- otb/cmakemodules/*.cmake files added to installed files
- Mapnik disabled
- Default Python version used

* Wed Mar 21 2012 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.12.0-1
- Packaging OTB 3.12 for CentOS 5.5

* Fri Dec 09 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.11.0-1
- Packaging OTB 3.11 for CentOS 5.5

* Thu Jul 07 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-3
- Dependencies improved

* Tue Jul 05 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-2
- Packaging OTB 3.10 for CentOS 5.5

* Mon May 02 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.8.0-2
- Packaging OTB 3.8 for CentOS 5.5

* Fri Dec 10 2010 Angelos Tzotsos <tzotsos@gmail.com> - 3.8.0-1
- Initial build
- Packaging for OpenSuse
