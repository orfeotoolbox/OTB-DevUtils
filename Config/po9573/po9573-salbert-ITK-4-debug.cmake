SET(ENV{DISPLAY} ":0.0")

set (CTEST_BUILD_CONFIGURATION "Debug")
# set (CTEST_BUILD_CONFIGURATION "Release")

set( CTEST_ITK_VERSION "4.13" )

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/ssd/dev")
set(CTEST_SITE "po9573.c-s.fr")
set(CTEST_BUILD_NAME "OrfeoToolbox-Ubuntu-18.04_x86_64-${CTEST_BUILD_CONFIGURATION}")
#  set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )

set(dashboard_root_name "tests")
set(dashboard_source_name "source/ITK")
set(dashboard_binary_name "build/ITK-${CTEST_ITK_VERSION}-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "http://itk.org/ITK.git")
set(dashboard_git_branch "v${CTEST_ITL_VERSION}")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra

# CMAKE_INSTALL_PREFIX:PATH=$ENV{HOME}/local
CMAKE_INSTALL_PREFIX:PATH=$ENV{HOME}/ssd/dev/install/ITK-${CTEST_ITK_VERSION}-${CTEST_BUILD_CONFIGURATION}

BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF

ExternalData_OBJECT_STORES:PATH=${CTEST_DASHBOARD_ROOT}/ITKv4-ExternalObjectStores

# ITK_BUILD_DEFAULT_MODULES:BOOL=OFF
ITK_BUILD_DEFAULT_MODULES:BOOL=ON

# as much external libraries as possible
# libtiff on ubuntu does not support BigTIFF and is incompatible with ITK
ITK_USE_SYSTEM_HDF5:BOOL=ON
ITK_USE_SYSTEM_GDCM:BOOL=OFF
ITK_USE_SYSTEM_JPEG:BOOL=ON
ITK_USE_SYSTEM_PNG:BOOL=ON
ITK_USE_SYSTEM_TIFF:BOOL=OFF
ITK_USE_SYSTEM_ZLIB:BOOL=ON
# ITK_USE_SYSTEM_DOUBLECONVERSION:BOOL=ON

# OTB depends on this
ITK_USE_FFTWF:BOOL=ON
ITK_USE_FFTWD:BOOL=ON
ITK_USE_SYSTEM_FFTW:BOOL=ON

ITK_LEGACY_REMOVE:BOOL=ON

# Module_ITKCommon:BOOL=ON
# Module_ITKFiniteDifference:BOOL=ON
# Module_ITKGPUCommon:BOOL=ON
# Module_ITKGPUFiniteDifference:BOOL=ON
# Module_ITKImageAdaptors:BOOL=ON
# Module_ITKImageFunction:BOOL=ON
# Module_ITKMesh:BOOL=ON
# Module_ITKQuadEdgeMesh:BOOL=ON
# Module_ITKSpatialObjects:BOOL=ON
# # Module_ITKTestKernel:BOOL=ON
# Module_ITKTransform:BOOL=ON

# Module_ITKAnisotropicSmoothing:BOOL=ON
# Module_ITKAntiAlias:BOOL=ON
# Module_ITKBiasCorrection:BOOL=ON
# Module_ITKBinaryMathematicalMorphology:BOOL=ON
# Module_ITKColormap:BOOL=ON
# Module_ITKConvolution:BOOL=ON
# Module_ITKCurvatureFlow:BOOL=ON
# Module_ITKDeconvolution:BOOL=ON
# Module_ITKDenoising:BOOL=ON
# # Module_ITKDiffusionTensorImage:BOOL=ON
# Module_ITKDisplacementField:BOOL=ON
# Module_ITKDistanceMap:BOOL=ON
# Module_ITKFastMarching:BOOL=ON
# Module_ITKFFT:BOOL=ON
# Module_ITKGPUAnisotropicSmoothing:BOOL=ON
# Module_ITKGPUImageFilterBase:BOOL=ON
# Module_ITKGPUSmoothing:BOOL=ON
# Module_ITKGPUThresholding:BOOL=ON
# Module_ITKImageCompare:BOOL=ON
# Module_ITKImageCompose:BOOL=ON
# Module_ITKImageFeature:BOOL=ON
# Module_ITKImageFilterBase:BOOL=ON
# Module_ITKImageFusion:BOOL=ON
# Module_ITKImageGradient:BOOL=ON
# Module_ITKImageGrid:BOOL=ON
# Module_ITKImageIntensity:BOOL=ON
# Module_ITKImageLabel:BOOL=ON
# Module_ITKImageSources:BOOL=ON
# Module_ITKImageStatistics:BOOL=ON
# Module_ITKLabelMap:BOOL=ON
# Module_ITKMathematicalMorphology:BOOL=ON
# Module_ITKPath:BOOL=ON
# Module_ITKQuadEdgeMeshFiltering:BOOL=ON
# Module_ITKSmoothing:BOOL=ON
# Module_ITKSpatialFunction:BOOL=ON
# Module_ITKThresholding:BOOL=ON

# Module_ITKEigen:BOOL=ON
# # Module_ITKFEM:BOOL=ON
# Module_ITKNarrowBand:BOOL=ON
# Module_ITKNeuralNetworks:BOOL=ON
# Module_ITKOptimizers:BOOL=ON
# Module_ITKOptimizersv4:BOOL=ON
# Module_ITKPolynomials:BOOL=ON
# Module_ITKStatistics:BOOL=ON

# Module_ITKRegistrationCommon:BOOL=ON
# # Module_ITKFEMRegistration:BOOL=ON
# Module_ITKGPURegistrationCommon:BOOL=ON
# Module_ITKGPUPDEDeformableRegistration:BOOL=ON
# Module_ITKMetricsv4:BOOL=ON
# Module_ITKPDEDeformableRegistration:BOOL=ON
# Module_ITKRegistrationMethodsv4:BOOL=ON

# # Module_ITKBioCell:BOOL=ON
# Module_ITKClassifiers:BOOL=ON
# Module_ITKConnectedComponents:BOOL=ON
# Module_ITKDeformableMesh:BOOL=ON
# Module_ITKKLMRegionGrowing:BOOL=ON
# Module_ITKLabelVoting:BOOL=ON
# Module_ITKLevelSets:BOOL=ON
# Module_ITKLevelSetsv4:BOOL=ON
# # Module_ITKLevelSetsv4Visualization:BOOL=ON
# Module_ITKMarkovRandomFieldsClassifiers:BOOL=ON
# Module_ITKRegionGrowing:BOOL=ON
# Module_ITKSignedDistanceFunction:BOOL=ON
# Module_ITKVoronoi:BOOL=ON
# Module_ITKWatersheds:BOOL=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../itk_common.cmake)
