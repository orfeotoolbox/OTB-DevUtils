# Client maintainer: manuel.grizonnet@cnes.fr

SET(MAKECOMMAND "/usr/bin/make -i -k -j 4" CACHE STRING "" FORCE)
# Name of the build
SET(BUILDNAME "ITKv4-nopatch-Internal-Fedora17-64bits-Install-Testing-Debug" CACHE STRING "" FORCE)
# Name of the computer/site where compile is being run
SET(SITE "pc-christophe.cst.cnes.fr" CACHE STRING "" FORCE)

# Compilation options
SET(CMAKE_C_FLAGS "-Wall -Wno-uninitialized -Wno-unused-variable" CACHE STRING "" FORCE)
SET(CMAKE_CXX_FLAGS "-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable" CACHE STRING "" FORCE)

SET(OTB_DATA_USE_LARGEINPUT ON CACHE BOOL "" FORCE)
SET(OTB_DATA_LARGEINPUT_ROOT "/media/ssh/pc-inglada/media/TeraDisk2/LargeInput" CACHE STRING "" FORCE)
# Data root
SET(OTB_DATA_ROOT "$ENV{HOME}/OTB/trunk/OTB-ITKv4-Data" CACHE STRING "" FORCE)
# Set up the build options
SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
SET(OTB_DIR "$ENV{HOME}/OTB/bin/OTB-ITKv4-nopatch-SHOW_ALL_MSG_DEBUG-INSTALL" CACHE STRING "" FORCE)
