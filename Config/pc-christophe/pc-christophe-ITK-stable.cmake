# Client maintainer: manuel.grizonnet@cnes.fr

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "ITK-release_branch-Fedora22-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/itk/stable")
set(dashboard_binary_name "build/itk/stable/${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout ON)
set(dashboard_git_url "http://itk.org/ITK.git")
set(dashboard_git_branch "release")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}/install")
set (ITK_INSTALL_PREFIX "${INSTALLROOT}/itk/stable/${CTEST_BUILD_CONFIGURATION}")

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${ITK_INSTALL_PREFIX})

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wextra -Wunused-local-typedefs -std=c++11
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_INSTALL_PREFIX=${ITK_INSTALL_PREFIX}

BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

# as much external libraries as possible
# libtiff on ubuntu does not support BigTIFF and is incompatible with ITK
ITK_USE_SYSTEM_HDF5:BOOL=ON
ITK_USE_SYSTEM_PNG:BOOL=ON #will have test failing in itkSingedMaurerDistanceMap... in ITK dashboard
ITK_USE_SYSTEM_TIFF:BOOL=ON
ITK_USE_SYSTEM_ZLIB:BOOL=ON
ITK_USE_SYSTEM_EXPAT:BOOL=ON #since itkv4.6

# Enable system jpeg, gdcm and use openjpeg2.0 build with libgdal 
# to prevent symbol conflict. For more info refer to wiki
# http://wiki.orfeo-toolbox.org/index.php/JPEG2000_with_GDAL_OpenJpeg_plugin
ITK_USE_SYSTEM_GDCM:BOOL=ON
ITK_USE_SYSTEM_JPEG:BOOL=ON
JPEG_INCLUDE_DIR:PATH=${INSTALLROOT}/openjpeg/stable/include/openjpeg-2.0
JPEG_LIBRARY:FILEPATH=${INSTALLROOT}/openjpeg/stable/lib/libopenjp2.so

# OTB depends on this
ITK_USE_FFTWF:BOOL=ON
ITK_USE_FFTWD:BOOL=ON
ITK_USE_SYSTEM_FFTW:BOOL=ON

ITK_LEGACY_REMOVE=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
