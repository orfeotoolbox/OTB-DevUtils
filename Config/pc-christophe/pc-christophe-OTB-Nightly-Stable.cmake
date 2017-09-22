# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(OTB_PROJECT OTB)
set(CTEST_BUILD_CONFIGURATION Release)
include(${CTEST_SCRIPT_DIRECTORY}/pc-christophe_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(CTEST_BUILD_NAME "Fedora22-64bits-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")
string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-Stable/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_git_url "http://git@git.orfeo-toolbox.org/git/otb.git")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}/install")
set (CTEST_INSTALL_DIRECTORY "${INSTALLROOT}/orfeo/trunk/OTB-Nightly-Stable/${CTEST_BUILD_CONFIGURATION}")

macro(dashboard_hook_init)

# NOTE: -Wno-deprecated-declarations is in CXX flags to hide 'itkLegacyMacro' related warning
# under gcc 5.1.1, to work around GCC bug 65974.
# It should be removed when gcc is updated on pc-christophe

set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall -Wextra
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-cpp -Wextra -Wno-deprecated-declarations -fopenmp --std=c++11
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data

## ITK
ITK_DIR:PATH=/home/otbtesting/build/itk/stable/Release

## OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/release/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/release/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/stable/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/stable/include/muparserx


PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

# Comment QWT include and libs
# QWT_INCLUDE_DIR:PATH=/usr/include/qwt
# QWT_LIBRARY:FILEPATH=/usr/lib64/libqwt.so

#OTB_USE_XXX
OTB_USE_6S=ON
OTB_USE_CURL=ON
OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4=ON
OTB_USE_SIFTFAST=ON
# Ice/Monteverdi module
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_QWT:BOOL=ON
 ")

endmacro()

#remove install dir
#execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
