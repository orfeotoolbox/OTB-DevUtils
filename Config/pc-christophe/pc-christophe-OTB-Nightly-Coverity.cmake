# Client maintainer: manuel.grizonnet@cnes.fr
# Make command for parallel builds
SET(MAKECOMMAND "/usr/bin/make -k -j 4" CACHE STRING "" FORCE)
# Name of the build
SET(BUILDNAME "Fedora22-64bits-Coverity-Debug" CACHE STRING "" FORCE)
# Name of the computer/site where compile is being run
SET(SITE "pc-christophe.cst.cnes.fr" CACHE STRING "" FORCE)
# LargeInput
SET(OTB_DATA_USE_LARGEINPUT ON CACHE BOOL "" FORCE)
SET(OTB_DATA_LARGEINPUT_ROOT "/media/TeraDisk2/LargeInput" CACHE STRING "" FORCE)
# Data root
SET(OTB_DATA_ROOT "/home/otbtesting/sources/orfeo/OTB-Data" CACHE STRING "" FORCE)
# Set up the build options
SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)

#SET(CMAKE_C_FLAGS "-Wall -Wextra -Wno-unused-parameter" CACHE STRING "" FORCE)
SET(CMAKE_CXX_FLAGS "-std=c++11" CACHE STRING "" FORCE)

SET(BUILD_TESTING ON CACHE BOOL "" FORCE)
SET(BUILD_EXAMPLES ON CACHE BOOL "" FORCE)
SET(BUILD_APPLICATIONS ON CACHE BOOL "" FORCE)

##external ITK
SET(ITK_DIR "/home/otbtesting/build/itk/stable/Release" CACHE STRING "" FORCE)

##external OSSIM
SET(OSSIM_INCLUDE_DIR "/home/otbtesting/install/ossim/release/include" CACHE STRING "" FORCE)
SET(OSSIM_LIBRARY "/home/otbtesting/install/ossim/release/lib64/libossim.so" CACHE STRING "" FORCE)

##external muparserx
SET(MUPARSERX_LIBRARY "/home/otbtesting/install/muparserx/stable/lib/libmuparserx.so" CACHE STRING "" FORCE)
SET(MUPARSERX_INCLUDE_DIR "/home/otbtesting/install/muparserx/stable/include/muparserx" CACHE STRING "" FORCE)


# Qwt
SET(QWT_INCLUDE_DIR "/usr/include/qwt5-qt4" CACHE STRING "" FORCE)
SET(QWT_LIBRARY "/usr/lib64/libqwt.so.5"  CACHE STRING "" FORCE)

# These options are not available anymore
SET(OTB_USE_PATENTED ON CACHE BOOL "" FORCE)
SET(OTB_USE_CURL ON CACHE BOOL "" FORCE)

SET(OTB_USE_MAPNIK OFF CACHE BOOL "" FORCE)
SET(OTB_USE_OPENCV ON CACHE BOOL "" FORCE)
SET(OTB_USE_QT4 ON CACHE BOOL "" FORCE)
SET(OTB_USE_MUPARSER ON CACHE BOOL "" FORCE)
SET(OTB_USE_MUPARSERX ON CACHE BOOL "" FORCE)
SET(OTB_USE_LIBKML OFF CACHE BOOL "" FORCE)
SET(OTB_USE_6S ON CACHE BOOL "" FORCE)
SET(OTB_USE_SIFTFAST ON CACHE BOOL "" FORCE)
SET(OTB_USE_LIBSVM ON CACHE BOOL "" FORCE)
SET(OTB_USE_CURL ON CACHE BOOL "" FORCE)
SET(OTB_USE_GLEW ON CACHE BOOL "" FORCE)
SET(OTB_USE_GLUT ON CACHE BOOL "" FORCE)
SET(OTB_USE_GLFW ON CACHE BOOL "" FORCE)
SET(OTB_USE_OPENGL ON CACHE BOOL "" FORCE)
SET(OTB_USE_QWT ON CACHE BOOL "" FORCE)

SET(OTB_WRAP_JAVA ON CACHE BOOL "" FORCE)
SET(OTB_WRAP_PYTHON ON CACHE BOOL "" FORCE)

SET(PYTHON_EXECUTABLE "/usr/bin/python" CACHE STRING "" FORCE)
