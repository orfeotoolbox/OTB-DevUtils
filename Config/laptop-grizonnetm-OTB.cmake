SET(BUILDNAME "laptop-grizonnetm-release" CACHE STRING "" FORCE)
SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
SET(BUILD_TESTING ON CACHE BOOL "" FORCE)
SET(BUILD_EXAMPLES ON CACHE BOOL "" FORCE)

SET(MAKECOMMAND "make all -j 8" CACHE STRING "" FORCE)
SET(OTB_DATA_ROOT "/home/grizonnetm/projets/otb/src/OTB-Data" CACHE STRING "" FORCE)
SET(OTB_USE_EXTERNAL_FLTK ON CACHE BOOL "" FORCE)

#set gdal options
SET(GDAL_INCLUDE_DIR "/home/grizonnetm/local/gdal-1.8/include" CACHE PATH "" FORCE)
SET(GDAL_LIBRARY "/home/grizonnetm/local/lib/libgdal.so" CACHE PATH "" FORCE)
SET(GDAL_CONFIG "/home/grizonnetm/Local/gdal-1.7.1-build/bin/gdal-config" CACHE PATH "" FORCE)
SET(OGR_INCLUDE_DIRS "/home/grizonnetm/Local/gdal-1.7.1-build/include"  CACHE PATH "" FORCE) 

SET(GEOTIFF_INCLUDE_DIRS "/home/grizonnetm/local/gdal-1.8/include" CACHE PATH "" FORCE)
SET(GEOTIFF_LIBRARY "/home/grizonnetm/local/gdal-1.8/lib/libgdal.so" CACHE PATH "" FORCE)

#use internal gdal tiff library to enable bigtiff 
SET(TIFF_INCLUDE_DIRS "/home/grizonnetm/local/gdal-1.8/include" CACHE PATH "" FORCE)
SET(TIFF_LIBRARY "/home/grizonnetm/local/gdal-1.8/lib/libgdal.so" CACHE PATH "" FORCE)

#Name of the computer/site where compile is being run
SET(SITE "laptop-grizonnetm"  CACHE PATH "" FORCE)
#LargeInput
SET(OTB_DATA_USE_LARGEINPUT ON CACHE BOOL "" FORCE)
SET(OTB_DATA_LARGEINPUT_ROOT "/remote/TeraDisk/OTB/trunk/OTB-Data/LargeInput"  CACHE PATH "" FORCE)
#Data root
SET(OTB_DATA_ROOT "/remote/TeraDisk/OTB/trunk/OTB-Data"  CACHE PATH "" FORCE)
#Compilation options
SET(CMAKE_C_FLAGS "-Wall -Wno-uninitialized -Wno-unused-variable"  CACHE PATH "" FORCE)
SET(CMAKE_CXX_FLAGS:STRING "-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable"  CACHE PATH "" FORCE)

SET(OTB_USE_CURL ON CACHE BOOL "" FORCE)
SET(OTB_USE_PQXX ON CACHE BOOL "" FORCE)
SET(OTB_USE_EXTERNAL_BOOST ON CACHE BOOL "" FORCE)
SET(OTB_USE_EXTERNAL_EXPAT ON CACHE BOOL "" FORCE)
SET(OTB_USE_DEPRECATED ON CACHE BOOL "" FORCE)
SET(ITK_USE_PATENTED ON  CACHE BOOL "" FORCE)
SET(OTB_USE_PATENTED  ON  CACHE BOOL "" FORCE)
SET(USE_FFTWD  ON  CACHE BOOL "" FORCE)
SET(USE_FFTWF  ON  CACHE BOOL "" FORCE)
SET(OTB_GL_USE_ACCEL  ON  CACHE BOOL "" FORCE)) 
SET(ITK_USE_REVIEW ON  CACHE BOOL "" FORCE) 
SET(ITK_USE_OPTIMIZED_REGISTRATION_METHODS ON  CACHE BOOL "" FORCE) 
SET(OTB_USE_MAPNIK  ON  CACHE BOOL "" FORCE) 
#Mapnik configuration
SET(MAPNIK_INCLUDE_DIR:STRING "/usr/include"   CACHE PATH "" FORCE)
SET(MAPNIK_LIBRARY:STRING "/usr/lib/libmapnik.so"   CACHE PATH "" FORCE)

