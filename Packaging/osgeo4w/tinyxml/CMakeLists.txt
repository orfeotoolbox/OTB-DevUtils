cmake_minimum_required(VERSION 2.8.3)

project(tinyXML)

option(BUILD_SHARED_LIBS "Build shared libs" OFF)


# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()


file(GLOB tinyXMLlib_SRCS "*.cpp")
file(GLOB tinyXMLlib_HDRS "*.h")
add_library(tinyxml ${tinyXMLlib_SRCS})

install(TARGETS tinyxml
    RUNTIME DESTINATION bin COMPONENT RuntimeLibraries
    LIBRARY DESTINATION lib COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION lib COMPONENT Development)

install(FILES ${tinyXMLlib_HDRS}
    DESTINATION include
    COMPONENT Development)


#set(TINYXML_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})
#set(TINYXML_LIBRARIES tinyXML)
