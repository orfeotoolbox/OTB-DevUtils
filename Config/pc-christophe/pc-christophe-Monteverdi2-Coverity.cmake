# Client maintainer: manuel.grizonnet@cnes.fr
# Make command for parallel builds
SET(MAKECOMMAND "/usr/bin/make -k -j 4" CACHE STRING "" FORCE)
# Name of the build
SET(BUILDNAME "Fedora22-64bits-Coverity-Debug" CACHE STRING "" FORCE)
# Name of the computer/site where compile is being run
SET(SITE "pc-christophe.cst.cnes.fr" CACHE STRING "" FORCE)
SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)

##external ITK
SET(ITK_DIR "/home/otbtesting/install/itk/stable/Release/lib/cmake/ITK-4.9" CACHE STRING "" FORCE)
SET(OTB_DIR "/home/otbtesting/install/orfeo/trunk/OTB-Nightly/Release/lib/cmake/OTB-5.3" CACHE STRING "" FORCE)

SET(BUILD_TESTING ON CACHE BOOL "" FORCE)

#otbIce
SET(ICE_INCLUDE_DIR "/home/otbtesting/install/orfeo/trunk/Ice/Release/include/" CACHE STRING "" FORCE)
SET(ICE_LIBRARY "/home/otbtesting/install/orfeo/trunk/Ice/Release/lib/libOTBIce.so" CACHE STRING "" FORCE)

SET(OTB_DATA_USE_LARGEINPUT ON CACHE BOOL "" FORCE)
SET(OTB_DATA_ROOT "/home/otbtesting/sources/orfeo/OTB-Data" CACHE STRING "" FORCE)
SET(OTB_DATA_LARGEINPUT_ROOT "/media/TeraDisk2/LargeInput" CACHE STRING "" FORCE)

#Qwt
SET(QWT_INCLUDE_DIR "/usr/include/qwt5-qt4" CACHE STRING "" FORCE)
SET(QWT_LIBRARY "/usr/lib64/libqwt.so.5" CACHE STRING "" FORCE)
