%define _ver_major      4
%define _ver_minor      8
%define _ver_release    1
%define sname    ITK-%{_ver_major}.%{_ver_minor}

%if 0%{?rhel} && 0%{?rhel} <= 5
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

Name:           InsightToolkit-otb
Summary:        Insight Segmentation and Registration Toolkit (ITK)
Version:        %{_ver_major}.%{_ver_minor}.%{_ver_release}
Release:        2%{?dist}
License:        ASL 2.0
Group:          Applications/Engineering
#the source tar.xz used to build ITK is actual release from 'Source0' - InsightToolkit/.ExternalData
##This is a snapshot version. commit hash is 999bf63dc19db7d3c586b3f299bd3db150e514f9
Source0:        http://sourceforge.net/projects/itk/files/itk/%{_ver_major}.%{_ver_minor}/%{name}-%{version}.tar.xz
#Source1:        http://downloads.sourceforge.net/project/itk/itk/4.7/InsightSoftwareGuide-Book1-4.7.1.pdf
#Source2:        http://downloads.sourceforge.net/project/itk/itk/4.7/InsightSoftwareGuide-Book2-4.7.1.pdf
URL:            http://www.itk.org/
Patch0:         %{name}-0001-Set-lib-according-to-the-arch.patch

BuildRequires:  cmake
BuildRequires:  fftw-devel
BuildRequires:  vxl-devel
BuildRequires:  zlib-devel
BuildRequires:  expat-devel

%description
ITK is an open-source software toolkit for performing registration and
segmentation. Segmentation is the process of identifying and classifying data
found in a digitally sampled representation. Typically the sampled
representation is an image acquired from such medical instrumentation as CT or
MRI scanners. Registration is the task of aligning or developing
correspondences between data. For example, in the medical environment, a CT
scan may be aligned with a MRI scan in order to combine the information
contained in both.

ITK is implemented in C++ and its implementation style is referred to as
generic programming (i.e.,using templated code). Such C++ templating means
that the code is highly efficient, and that many software problems are
discovered at compile-time, rather than at run-time during program execution.

%package        devel
Summary:        Insight Toolkit
Group:          Development/Libraries
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
%{summary}.
Install this if you want to develop applications that use ITK.

# %package        examples
# Summary:        C++, Tcl and Python example programs/scripts for ITK
# Group:          Development/Languages
# Requires:       %{name}%{?_isa} = %{version}-%{release}

# %description examples
# ITK examples

%package        doc
Summary:        Documentation for ITK
Group:          Documentation
BuildArch:      noarch

%description    doc
%{summary}.
This package contains additional documentation.

# Hit bug http://www.gccxml.org/Bug/view.php?id=13372
# We agreed with Mattias Ellert to postpone the bindings till
# next gccxml update.
#%package        python
#Summary:        Documentation for ITK
#Group:          Documentation
#BuildArch:      noarch

#%description    python
#%{summary}.
#This package contains python bindings for ITK.

# %package        vtk
# Summary:        Provides an interface between ITK and VTK
# Group:          System Environment/Libraries
# Requires:       %{name}%{?_isa} = %{version}-%{release}

# %description vtk
# Provides an interface between ITK and VTK

%prep
%setup -q
%patch0 -p1
#%patch1 -p1

# copy guide into the appropriate directory
#cp -a %{SOURCE1} %{SOURCE2} .

# remove applications: they are shipped separately now
rm -rf Applications/

# remove source files of external dependencies that itk gets linked against
for adir in DCMTK Expat GDCM HDF5 JPEG PNG TIFF VNL ZLIB; do
    find Modules/ThirdParty/${adir} -regextype posix-extended -type f \
    -regex ".*\.(h|hxx|hpp|c|cc|cpp|cxx|txx)$" -not -iname "itk*" -print0 | xargs -0 rm -fr
done

%build

mkdir -p %{_target_platform}
pushd %{_target_platform}

%cmake .. \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_EXAMPLES:BOOL=OFF \
       -DCMAKE_BUILD_TYPE:STRING="Release"\
       -DCMAKE_VERBOSE_MAKEFILE=OFF \
       -DBUILD_TESTING=OFF \
       -DITKGroup_Core:BOOL=OFF \
       -DITK_BUILD_DEFAULT_MODULES:BOOL=OFF \
       -DModule_ITKCommon:BOOL=ON \
       -DModule_ITKFiniteDifference:BOOL=ON \
       -DModule_ITKGPUCommon:BOOL=ON \
       -DModule_ITKGPUFiniteDifference:BOOL=ON \
       -DModule_ITKImageAdaptors:BOOL=ON \
       -DModule_ITKImageFunction:BOOL=ON \
       -DModule_ITKMesh:BOOL=ON \
       -DModule_ITKQuadEdgeMesh:BOOL=ON \
       -DModule_ITKSpatialObjects:BOOL=ON \
       -DModule_ITKTransform:BOOL=ON \
       -DModule_ITKAnisotropicSmoothing:BOOL=ON \
       -DModule_ITKAntiAlias:BOOL=ON \
       -DModule_ITKBiasCorrection:BOOL=ON \
       -DModule_ITKBinaryMathematicalMorphology:BOOL=ON \
       -DModule_ITKColormap:BOOL=ON \
       -DModule_ITKConvolution:BOOL=ON \
       -DModule_ITKCurvatureFlow:BOOL=ON \
       -DModule_ITKDeconvolution:BOOL=ON \
       -DModule_ITKDenoising:BOOL=ON \
       -DModule_ITKDisplacementField:BOOL=ON \
       -DModule_ITKDistanceMap:BOOL=ON \
       -DModule_ITKFastMarching:BOOL=ON \
       -DModule_ITKFFT:BOOL=ON \
       -DModule_ITKGPUAnisotropicSmoothing:BOOL=ON \
       -DModule_ITKGPUImageFilterBase:BOOL=ON \
       -DModule_ITKGPUSmoothing:BOOL=ON \
       -DModule_ITKGPUThresholding:BOOL=ON \
       -DModule_ITKImageCompare:BOOL=ON \
       -DModule_ITKImageCompose:BOOL=ON \
       -DModule_ITKImageFeature:BOOL=ON \
       -DModule_ITKImageFilterBase:BOOL=ON \
       -DModule_ITKImageFusion:BOOL=ON \
       -DModule_ITKImageGradient:BOOL=ON \
       -DModule_ITKImageGrid:BOOL=ON \
       -DModule_ITKImageIntensity:BOOL=ON \
       -DModule_ITKImageLabel:BOOL=ON \
       -DModule_ITKImageSources:BOOL=ON \
       -DModule_ITKImageStatistics:BOOL=ON \
       -DModule_ITKLabelMap:BOOL=ON \
       -DModule_ITKMathematicalMorphology:BOOL=ON \
       -DModule_ITKPath:BOOL=ON \
       -DModule_ITKQuadEdgeMeshFiltering:BOOL=ON \
       -DModule_ITKSmoothing:BOOL=ON \
       -DModule_ITKSpatialFunction:BOOL=ON \
       -DModule_ITKThresholding:BOOL=ON \
       -DModule_ITKEigen:BOOL=ON \
       -DModule_ITKNarrowBand:BOOL=ON \
       -DModule_ITKNeuralNetworks:BOOL=ON \
       -DModule_ITKOptimizers:BOOL=ON \
       -DModule_ITKOptimizersv4:BOOL=ON \
       -DModule_ITKPolynomials:BOOL=ON \
       -DModule_ITKStatistics:BOOL=ON \
       -DModule_ITKRegistrationCommon:BOOL=ON \
       -DModule_ITKGPURegistrationCommon:BOOL=ON \
       -DModule_ITKGPUPDEDeformableRegistration:BOOL=ON \
       -DModule_ITKMetricsv4:BOOL=ON \
       -DModule_ITKPDEDeformableRegistration:BOOL=ON \
       -DModule_ITKRegistrationMethodsv4:BOOL=ON \
       -DModule_ITKClassifiers:BOOL=ON \
       -DModule_ITKConnectedComponents:BOOL=ON \
       -DModule_ITKDeformableMesh:BOOL=ON \
       -DModule_ITKKLMRegionGrowing:BOOL=ON \
       -DModule_ITKLabelVoting:BOOL=ON \
       -DModule_ITKLevelSets:BOOL=ON \
       -DModule_ITKLevelSetsv4:BOOL=ON \
       -DModule_ITKMarkovRandomFieldsClassifiers:BOOL=ON \
       -DModule_ITKRegionGrowing:BOOL=ON \
       -DModule_ITKSignedDistanceFunction:BOOL=ON \
       -DModule_ITKVoronoi:BOOL=ON \
       -DModule_ITKWatersheds:BOOL=ON \
       -DUSE_FFTWF:BOOL=ON \
       -DUSE_FFTWD:BOOL=ON \
       -DITK_USE_SYSTEM_FFTW:BOOL=ON \
       -DITK_USE_SYSTEM_ZLIB:BOOL=ON \
       -DITK_WRAP_PYTHON:BOOL=OFF \
       -DITK_WRAP_JAVA:BOOL=OFF \
       -DBUILD_DOCUMENTATION:BOOL=OFF \
       -DITK_USE_SYSTEM_VXL=ON \
       -DITK_INSTALL_LIBRARY_DIR=%{_lib}/ \
       -DITK_INSTALL_INCLUDE_DIR=include/%{sname} \
       -DITK_INSTALL_PACKAGE_DIR=%{_lib}/cmake/%{sname}/ \
       -DITK_INSTALL_RUNTIME_DIR:PATH=%{_bindir} \
       -DITK_INSTALL_DOC_DIR=share/doc/%{sname}/


popd

make %{?_smp_mflags} -C %{_target_platform}

%install
%make_install -C %{_target_platform}

# Install examples
###mkdir -p %{buildroot}%{_datadir}/%{sname}/examples
###cp -ar Examples/* %{buildroot}%{_datadir}/%{sname}/examples/

for f in LICENSE NOTICE README.txt ; do
    cp -p $f ${RPM_BUILD_ROOT}%{_docdir}/%{sname}/${f}
done

%check
# There are a couple of tests randomly failing on f19 and rawhide and I'm debugging
# it with upstream. Making the tests informative for now
make test -C %{_target_platform} || exit 0

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

#%post vtk -p /sbin/ldconfig

#%postun vtk -p /sbin/ldconfig

%files
%{_docdir}/%{sname}/
%{_libdir}/*.so.*
#%exclude %{_libdir}/libITKVtkGlue*.so.*
#%{_bindir}/itkTestDriver

%files devel
%{_libdir}/*.so
%{_libdir}/cmake/%{sname}/
%{_includedir}/%{sname}/

###%files examples
###%{_datadir}/%{sname}/examples

%files doc
%dir %{_docdir}/%{sname}/
%{_docdir}/%{sname}/*
#%doc InsightSoftwareGuide-Book1-4.7.1.pdf
#%doc InsightSoftwareGuide-Book2-4.7.1.pdf

# %files vtk
# %{_libdir}/libITKVtkGlue*.so.*

%changelog
* Thu Oct 30 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.8.1-1
- package specific for OTB without all default modules
- packaging only for Fedora 21

* Fri Apr 24 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.8.1-1
- update to ITK 4.8.1
- commit hash 999bf63dc19db7d3c586b3f299bd3db150e514f9

* Wed Apr 22 2015 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.7.1-2
- update to ITK 4.7.1
- deactivate ITK_Review
- Do not embed PDF inside RPM files
- removed unwanted patches

* Wed Nov 26 2014 Rashad Kanavath <rashad.kanavath@c-s.fr> - 4.6.1-2
- original spec from pkgs.fedoraproject.org/cgit/InsightToolkit.git
- deactivate compilation of testing
- set install dir to ITK-{version} instead of InsightToolkit

* Fri Oct 03 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.6.1-1
- Update to 4.6.1
- Dont compile with -fpermissive

* Fri Aug 15 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.6.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Tue Aug 12 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.6.0-2
- Remove source files of external dependencies
- Partially fixes bug #1076793

* Mon Aug 04 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.6.0-1
- Update to 4.6.0

* Fri Jun 06 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.5.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Wed May  7 2014 Tom Callaway <spot@fedoraproject.org> - 4.5.2-2
- rebuild for new R without bundled blas/lapack

* Thu Apr 17 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.5.2-1
- Update to version 4.5.2

* Sun Feb 16 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.5.1-1
- Update to version 4.5.1

* Sun Jan 26 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.5.0-4
- Require netcdf-cxx-devel instead of netcdf-devel

* Sun Jan 26 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.5.0-3
- Add jsoncpp-devel to BuildRequires (needed for vtk 6.1)

* Sun Jan 26 2014 Sebastian Pölsterl <sebp@k-d-w.org> - 4.5.0-2
- Rebuilt for vtk 6.1 update

* Sun Dec 29 2013 Sebastian Pölsterl <sebp@k-d-w.org> - 4.5.0-1
- Update to version 4.5.0
- Update software guide to 4.5.0
- Include LICENSE, NOTICE and README.txt in base package
- Move ITK-VTK bridge to new vtk subpackage
- Add BuildRequires on netcdf-devel (required by vtk)

* Mon Dec 23 2013 Sebastian Poelsterl <sebp@k-d-w.org> - 4.4.2-6
- Add BuildRequires on blas-devel and lapack-devel

* Mon Dec 23 2013 Sebastian Poelsterl <sebp@k-d-w.org> - 4.4.2-5
- Rebuilt for updated vtk

* Tue Oct 29 2013 Mario Ceresa <mrceresa@fedoraproject.org> - 4.4.2-4
- Revision bump up to build against updated gdcm

* Fri Oct 25 2013 Sebastian Pölsterl <sebp@k-d-w.org> - 4.4.2-3
- Removed HDF5 patch that seems to interfere with cmake 2.8.12

* Tue Oct 22 2013 Sebastian Pölsterl <sebp@k-d-w.org> - 4.4.2-2
- Rebuilt for gdcm 2.4.0

* Sun Sep 08 2013 Sebastian Pölsterl <sebp@k-d-w.org> - 4.4.2-1
- Update to version 4.4.2
- Added patch to only link against HDF5 release libraries

* Wed Aug 14 2013 Mario Ceresa <mrceresa@fedoraproject.org> 4.4.1-2
- Re-enabled vtk support
- Re-enabled tests
- Added BR qtwebkit

* Tue Aug 13 2013 Sebastian Pölsterl <sebp@k-d-w.org> - 4.4.1-1
- Update to version 4.4.1

* Mon Aug 05 2013 Mario Ceresa <mrceresa AT fedoraproject DOT org> - 4.4.0-6
- Use unversioned doc
- Fixed bogus dates
- Temporary remove vtk support because of issues with texlive in rawhide

* Fri Aug 02 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.4.0-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Tue Jul 16 2013 Mario Ceresa <mrceresa@fedoraproject.org> 4.4.0-4
- Use xz tarball to save space in srpm media. (Fixes BZ980599)

* Fri Jul 12 2013 Orion Poplawski <orion@cora.nwra.com> 4.4.0-3
- Rebuild for vtk 6.0.0

* Wed Jul 10 2013 Mario Ceresa mrceresa fedoraproject org 4.4.0-2
- Devel package now requires vtk-devel because it is build with itkvtkglue mod
- Minor cleanups

* Mon Jul 08 2013 Mario Ceresa mrceresa fedoraproject org 4.4.0-1
- Contributed by Sebastian Pölsterl <sebp@k-d-w.org>
- Updated to upstream version 4.4.0
- Add VTK Glue module
- Removed obsolete TIFF patch

* Thu May 16 2013 Orion Poplawski <orion@cora.nwra.com> - 4.3.1-12
- Rebuild for hdf5 1.8.11

* Thu May 2 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-11
- Rebuilt for gdcm 2.3.2

* Fri Apr 26 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-10
- Install itkTestDriver in default package
- Install libraries into _libdir and drop ldconfig file

* Tue Apr 23 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-9
- Changed license to ASL 2.0

* Mon Apr 22 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-8
- Build examples
- Making tests informative as we debug it with upstream
- Fixed cmake support file location
- Disabled python bindings for now, hit http://www.gccxml.org/Bug/view.php?id=13372

* Sat Apr 20 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-7
- Enabled v3.20 compatibility layer

* Thu Apr 18 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-6
- Removed unused patches

* Mon Apr 08 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-5
- Fixed failing tests

* Wed Apr 03 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-4
- Fixed build with USE_SYSTEM_TIFF

* Fri Mar 29 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-3
- Compiles against VXL with compatibility patches
- Enabled testing

* Tue Feb 12 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-2
- Reorganized sections
- Fixed patch naming
- Removed buildroot and rm in install section
- Removed cmake version constraint
- Changed BR libjpeg-turbo-devel to libjpeg-devel
- Preserve timestamp of SOURCE1 file.
- Fixed main file section
- Added noreplace

* Fri Jan 25 2013 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.3.1-1
- Updated to 4.3.1
- Fixed conflicts with previous patches
- Dropped gcc from BR
- Fixed tabs-vs-space
- Improved description
- Re-enabled system tiff
- Clean up the spec
- Sanitize use of dir macro
- Re-organized docs
- Fixed libdir and datadir ownership

* Wed Dec 12 2012 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.2.1-4
- Included improvements to the spec file from Dan Vratil

* Tue Dec 4 2012 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.2.1-3
- Build against system VXL

* Mon Nov 26 2012 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.2.1-2
- Reorganized install paths

* Tue Nov 20 2012 Mario Ceresa mrceresa fedoraproject org InsightToolkit 4.2.1-1
- Updated to new version

* Wed Nov 30 2011 Mario Ceresa mrceresa fedoraproject org InsightToolkit 3.20.1-1
- Updated to new version
- Added binary morphology code

* Fri May 27 2011 Mario Ceresa mrceresa fedoraproject org InsightToolkit 3.20.0-5
- Added cstddef patch for gcc 4.6

* Mon Jan 24 2011 Mario Ceresa mrceresa@gmail.com InsightToolkit 3.20.0-4
- Added the ld.so.conf file

* Mon Nov 22 2010 Mario Ceresa mrceresa@gmail.com InsightToolkit 3.20.0-3
- Updated to 3.20 release
- Added vxl utility and review material
- Applied patch from upstream to fix vtk detection (Thanks to Mathieu Malaterre)
- Added patch to install in the proper lib dir based on arch value
- Added patch to set datadir as cmake configuration files dir

* Sun Dec  6 2009 Mario Ceresa mrceresa@gmail.com InsightToolkit 3.16.0-2
- Fixed comments from revision: https://bugzilla.redhat.com/show_bug.cgi?id=539387#c8

* Tue Nov 17 2009 Mario Ceresa mrceresa@gmail.com InsightToolkit 3.16.0-1
- Initial RPM Release
