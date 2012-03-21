# spec file for package OrfeoToolbox-Applications

# norootforbuild

Name:           OrfeoToolbox-Applications
Version:        3.12.0
Release:        1
Summary:        Applications based on OrfeoToolbox for remote sensing image processing
Group:          Applications/Image
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

BuildRequires:  cmake gdal-devel libgeotiff-devel gcc-c++ gcc freeglut-devel libpng-devel
BuildRequires:  boost-devel fltk-devel fltk-fluid qt4-devel
BuildRequires:  OrfeoToolbox-devel OrfeoToolbox

Requires:       OrfeoToolbox = 3.12.0


%description
Orfeo Toolbox (OTB) is a library of image processing algorithms developed by
CNES in the frame of the ORFEO Accompaniment Program. OTB is based on the
medical image processing library ITK and offers particular functionalities for
remote sensing image processing in general and for high spatial resolution
images in particular. OTB is distributed under a free software license CeCILL
(similar to GNU GPL) to encourage contribution from users and to promote
reproducible research.

OTB Applications are a set of various command line interface (CLI) and
graphical interface (GUI) applications developped around the OTB library.

This package is a meta-package. It depends on all CLI an GUI applications and
libraries provided by OTB Applications.


%package legacy
Summary:        Legacy applications based on OrfeoToolbox library
Group:          Applications/Image
License:        Cecill
Requires:       fltk OrfeoToolbox = 3.12.0 OrfeoToolbox-Applications = 3.12.0


%description legacy
This package contains legacy applications and related libraries provided by
OTB Applications.


%package cli
Summary:        Command line applications based on OrfeoToolbox library
Group:          Applications/Image
License:        Cecill
Requires:       OrfeoToolbox = 3.12.0 OrfeoToolbox-Applications = 3.12.0


%description cli
This package contains command line interface applications and related
libraries provided by OTB Applications.


%package fltk
Summary:        FLTK applications based on OrfeoToolbox library
Group:          Applications/Image
License:        Cecill
Requires:       fltk OrfeoToolbox = 3.12.0 OrfeoToolbox-Applications = 3.12.0


%description fltk
This package contains FLTK toolkit based GUI applications ans related
libraries provided by OTB Applications.


%package qt
Summary:        Qt applications based on OrfeoToolbox library
Group:          Applications/Image
License:        Cecill
Requires:       qt4 qt4-x11 OrfeoToolbox = 3.12.0 OrfeoToolbox-Applications = 3.12.0


%description qt
This package contains Qt toolkit based GUI applications ans related libraries
provided by OTB Applications.


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
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DCMAKE_SKIP_RPATH:BOOL=ON \
      -DOTB_USE_QGIS:BOOL=OFF \
      -DOTB_USE_QT:BOOL=ON \
      -DOTB_DIR:PATH=%{_libdir} \
      -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/


make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}


%clean
rm -rf %{buildroot}
rm -rf ../temp


%post
/sbin/ldconfig


%post legacy
/sbin/ldconfig


%post cli
/sbin/ldconfig


%post fltk
/sbin/ldconfig


%post qt
/sbin/ldconfig


%postun
/sbin/ldconfig


%postun legacy
/sbin/ldconfig


%postun cli
/sbin/ldconfig


%postun fltk
/sbin/ldconfig


%postun qt
/sbin/ldconfig


%files
%defattr(-,root,root,-)
%{_libdir}/otb/libOTBProcessingChain.so
#%{_libdir}/otb/libOTBBandMath.so
#%{_libdir}/otb/libOTBBundleToPerfectSensor.so
#%{_libdir}/otb/libOTBCompareImages.so
#%{_libdir}/otb/libOTBConcatenateImages.so
#%{_libdir}/otb/libOTBConvert.so
%{_libdir}/otb/libOTBEstimateFeaturesStatistics.so
%{_libdir}/otb/libOTBEvaluateObjectDetectorResponse.so
#%{_libdir}/otb/libOTBExtractROIApplication.so
#%{_libdir}/otb/libOTBFineRegistration.so
#%{_libdir}/otb/libOTBKmzExport.so
%{_libdir}/otb/libOTBObjectDetector.so
#%{_libdir}/otb/libOTBOrthoRectification.so
#%{_libdir}/otb/libOTBQuicklook.so
#%{_libdir}/otb/libOTBReadImageInfo.so
#%{_libdir}/otb/libOTBSplitImage.so
%{_libdir}/otb/libOTBTrainDeepSVMObjectDetector.so
%{_libdir}/otb/libOTBTrainObjectDetector.so
#%{_libdir}/otb/libOTBVectorDataSetField.so
#%{_libdir}/otb/libOTBComputePolylineFeatureFromImage.so
#%{_libdir}/otb/libOTBConcatenateVectorData.so
#%{_libdir}/otb/libOTBConnectedComponentSegmentation.so
#%{_libdir}/otb/libOTBDEMConvert.so
#%{_libdir}/otb/libOTBDSFuzzyModelEstimation.so
#%{_libdir}/otb/libOTBEstimateImagesStatistics.so
%{_libdir}/otb/libOTBEvaluateHOGObjectDetectorResponse.so
%{_libdir}/otb/libOTBHOGObjectDetector.so
%{_libdir}/otb/libOTBImageSimulator.so
#%{_libdir}/otb/libOTBImageSVMClassifier.so
%{_libdir}/otb/libOTBLAIAndPROSAILToSensorResponse.so
%{_libdir}/otb/libOTBLAIFromNDVIImageTransform.so
#%{_libdir}/otb/libOTBLabeledImageColorMapping.so
#%{_libdir}/otb/libOTBLineSegmentDetection.so
#%{_libdir}/otb/libOTBMaskGenerator.so
%{_libdir}/otb/libOTBMeanShiftModesDetection.so
#%{_libdir}/otb/libOTBMultiResolutionPyramid.so
#%{_libdir}/otb/libOTBOSMDownloader.so
#%{_libdir}/otb/libOTBOpticalCalibration.so
#%{_libdir}/otb/libOTBRasterization.so
#%{_libdir}/otb/libOTBRigidTransformResample.so
#%{_libdir}/otb/libOTBStereoSensorModelToElevationMap.so
#%{_libdir}/otb/libOTBSuperimpose.so
%{_libdir}/otb/libOTBTrainHOGObjectDetector.so
#%{_libdir}/otb/libOTBTrainImagesClassifier.so
#%{_libdir}/otb/libOTBValidateImagesClassifier.so
#%{_libdir}/otb/libOTBVectorDataDSValidation.so
#%{_libdir}/otb/libOTBVectorDataExtractROIApplication.so
#%{_libdir}/otb/libOTBVectorDataTransformFilterApplication.so


%files legacy
%defattr(-,root,root,-)
%{_bindir}/otbActiveLearning
%{_bindir}/otbFineRegistrationApplication
%{_bindir}/otbImageViewer
#%{_bindir}/otbImageViewerManager
#%{_bindir}/otbImageViewerManagerOld
#%{_bindir}/otbKMeansClassification
%{_bindir}/otbLandCoverMapApplication
%{_bindir}/otbLandCoverMapGenerateFeatures
%{_bindir}/otbObjectCountingApplication
%{_bindir}/otbPolarimetricSynthesisApplication
%{_bindir}/otbPolarimetricSynthesisCommandLine
#%{_bindir}/otbRgbRelabeling
%{_bindir}/otbRoadExtractionApplication
#%{_bindir}/otbSOMClassification
#%{_bindir}/otbSVMClassification
%{_bindir}/otbSegmentationApplication
%{_bindir}/otbStereoscopicApplication
#%{_bindir}/otbUnsignedShortRelabeling
%{_bindir}/otbUrbanAreaExtractionApplication
%{_libdir}/otb/libOTBApplicationsCommon.so
%{_libdir}/otb/libotbMVCFineRegistration.so
#%{_libdir}/otb/libotbMVCImageViewerManager.so
%{_libdir}/otb/libotbMVCLandCoverMap.so
%{_libdir}/otb/libotbMVCObjectCounting.so
%{_libdir}/otb/libotbMVCPolarimetricSynthesis.so
%{_libdir}/otb/libotbMVCRoadExtraction.so
%{_libdir}/otb/libotbMVCSegmentation.so
%{_libdir}/otb/libotbMVCStereoscopic.so
%{_libdir}/otb/libotbMVCUrbanArea.so


%files cli
%defattr(-,root,root,-)
%{_bindir}/otb*-cli
#%{_bindir}/otbConvertCartoToGeoPoint
#%{_bindir}/otbConvertGeoToCartoPoint
#%{_bindir}/otbConvertSensorToGeoPoint
#%{_bindir}/otbImageEnvelope
#%{_bindir}/otbObtainUTMZoneFromGeoPoint
%{_bindir}/otbOrthoInfo
%{_libdir}/otb/libOTBCommandLineGenerator.so


%files fltk
%defattr(-,root,root,-)
%{_bindir}/otb*-flgui
%{_libdir}/otb/libOTBFLTKGuiGenerator.so


%files qt
%defattr(-,root,root,-)
%{_bindir}/otb*-qtgui
%{_libdir}/otb/libOTBApplicationQtWidget.so


%changelog
* Wed Mar 21 2012 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.12.0-1
- Packaging OTB Applications 3.12 for CentOS 5.5

* Fri Dec 09 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.11.0-0
- Packaging OTB Applications 3.11 for CentOS 5.5

* Thu Jul 07 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-1
- Dependencies improved

* Tue Jul 05 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.10.0-0
- Packaging OTB-Applications 3.10 for CentOS 5.5

* Fri Jun 24 2011 Sebastien Dinot <sebastien.dinot@c-s.fr> - 3.8.0-1
- Initial build
- Packaging for CentOS 5.5
