# Client maintainer: manuel.grizonnet@cnes.fr
# Make command for parallel builds
SET(MAKECOMMAND "/usr/bin/make -i -k -j 4" CACHE STRING "" FORCE)
# Name of the build
SET(BUILDNAME "Fedora20-64bits-Coverity-Debug" CACHE STRING "" FORCE)
# Name of the computer/site where compile is being run
SET(SITE "pc-christophe.cst.cnes.fr" CACHE STRING "" FORCE)
SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)

##external ITK
SET(ITK_DIR "/home/otbtesting/install/itk/stable/Release/lib/cmake/ITK-4.6" CACHE STRING "" FORCE)
SET(OTB_DIR "/home/otbtesting/install/orfeo/trunk/OTB-Nightly/Release/lib/cmake/OTB-5.0" CACHE STRING "" FORCE)
SET(GLFW_INCLUDE_DIR "/usr/include/GLFW" CACHE STRING "" FORCE)

SET(BUILD_ICE_APPLICATION ON CACHE BOOL "" FORCE)
SET(BUILD_TESTING ON CACHE BOOL "" FORCE)
