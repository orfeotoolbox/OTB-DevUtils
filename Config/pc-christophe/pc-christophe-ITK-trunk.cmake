
# Client maintainer: julien.malik@c-s.fr
SET(ENV{DISPLAY} ":0.0")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "OrfeoToolBox-Fedora20-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)

set(dashboard_root_name "tests")
set(dashboard_source_name "code/ITK_trunk")
set(dashboard_binary_name "build/ITK_trunk-${CTEST_BUILD_CONFIGURATION}")


set(INSTALLROOT "/home/otbtesting/install")
set (ITK_INSTALL_PREFIX "${INSTALLROOT}/ITK_trunk-${CTEST_BUILD_CONFIGURATION}")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wextra -Wunsed-local-typedefs
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_INSTALL_PREFIX=${ITK_INSTALL_PREFIX}

BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

ExternalData_OBJECT_STORES:PATH=/home/otbtesting/OTB/trunk/ITKv4-ExternalObjectStores

# as much external libraries as possible
# libtiff on ubuntu does not support BigTIFF and is incompatible with ITK
ITK_USE_SYSTEM_HDF5:BOOL=ON
ITK_USE_SYSTEM_PNG:BOOL=OFF #due test failing in itkSingedMaurerDistanceMap..
ITK_USE_SYSTEM_TIFF:BOOL=ON
ITK_USE_SYSTEM_ZLIB:BOOL=ON
ITK_USE_SYSTEM_EXPAT:BOOL=ON

# Enable system jpeg, gdcm and use openjpeg2.0 build with libgdal 
# to prevent symbol conflict. For more info refer to wiki
# http://wiki.orfeo-toolbox.org/index.php/JPEG2000_with_GDAL_OpenJpeg_plugin
ITK_USE_SYSTEM_GDCM:BOOL=ON
ITK_USE_SYSTEM_JPEG:BOOL=ON
JPEG_INCLUDE_DIR:PATH=/home/otbtesting/install/include/openjpeg-2.0
JPEG_LIBRARY:FILEPATH=/home/otbtesting/install/lib/libopenjp2.so

# OTB depends on this
ITK_USE_FFTWF:BOOL=ON
ITK_USE_FFTWD:BOOL=ON
ITK_USE_SYSTEM_FFTW:BOOL=ON

ITK_LEGACY_REMOVE=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
