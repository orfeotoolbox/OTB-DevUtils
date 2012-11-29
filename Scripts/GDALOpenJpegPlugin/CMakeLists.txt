cmake_minimum_required(VERSION 2.8)
project(GDALOpenJpegPlugin)

find_package(GDAL)
find_package(OpenJPEG)

find_path(GDAL_SOURCE_DIR frmts/openjpeg/openjpegdataset.cpp)

include_directories(${GDAL_INCLUDE_DIRS})
include_directories(${OPENJPEG_INCLUDE_DIRS})

add_library(gdal_JP2OpenJPEG MODULE ${GDAL_SOURCE_DIR}/frmts/openjpeg/openjpegdataset.cpp)
target_link_libraries(gdal_JP2OpenJPEG ${GDAL_LIBRARIES} ${OPENJPEG_LIBRARIES})


