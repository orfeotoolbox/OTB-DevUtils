# Usual variables for projects using OTB
SET(BUILDNAME "Win32-VSExpress2008-Nightly-TestDriver-With-OSGEO-JAVA-ON-PYTHON-OFF" CACHE STRING "" FORCE)
SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
SET(CMAKE_CONFIGURATION_TYPES  "Release" CACHE PATH "" FORCE)
SET(MAKECOMMAND "C:\PROGRA~1\MICROS~1.0\Common7\IDE\VCExpress.exe OTB-Wrapping.sln /build Release /project ALL_BUILD" CACHE STRING "" FORCE)
SET(BUILD_TESTING ON CACHE BOOL "" FORCE)
SET(OTB_DIR "D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/OTB" CACHE PATH "" FORCE)
SET(OTB_DATA_ROOT "D:/Developpement/OTB-hg/OTB-Data" CACHE STRING "" FORCE)
SET(GDAL_INCLUDE_DIR "C:/OSGeo4W/apps/gdal-16/include" CACHE PATH "" FORCE)
SET(CMAKE_INSTALL_PREFIX "D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/install/Monteverdi" CACHE PATH "" FORCE)
SET(CPACK_PACKAGE_NAME "Wrapping-Nightly" CACHE STRING "" FORCE)

# Utilitites for Wrapping
SET(SWIG_DIR "D:/Developpement/OTB-OUTILS/swig/swigwin-1.3.40/Source/Swig" CACHE PATH "" FORCE)
SET(SWIG_EXECUTABLE "D:/Developpement/OTB-OUTILS/swig/swigwin-1.3.40/swig.exe" CACHE PATH "" FORCE)
SET(CableSwig_DIR   "D:/Developpement/OTB-OUTILS/cable_siwg/Cable-Swig-Bin" CACHE PATH "" FORCE)


# OTB Test driver to launch the tests
SET(OTB_TEST_DRIVER "D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/OTB/bin/Release/otbTestDriver.exe"  CACHE PATH "" FORCE)

# Select Languages to Wrap
SET(WRAP_ITK_JAVA ON CACHE BOOL "" FORCE)

# Java Stuffs
SET(JAVA_JVM_LIBRARY "C:\Program Files\Java\jdk1.6.0_14\lib\jvm.lib" CACHE PATH "" FORCE)
SET(JAVA_INCLUDE_PATH "C:\Program Files\Java\jdk1.6.0_14\include" CACHE PATH "" FORCE)
SET(JAVA_INCLUDE_PATH2 "C:\Program Files\Java\jdk1.6.0_14\include\win32" CACHE PATH "" FORCE)
SET(JAVA_AWT_INCLUDE "C:\Program Files\Java\jdk1.6.0_14\include" CACHE PATH "" FORCE)
SET(JAVA_RUNTIME "C:\Program Files\Java\jdk1.6.0_14\bin\java.exe" CACHE PATH "" FORCE)
SET(JAVA_COMPILE "C:\Program Files\Java\jdk1.6.0_14\bin\javac.exe" CACHE PATH "" FORCE)
SET(JAVA_ARCHIVE "C:\Program Files\Java\jdk1.6.0_14\bin\jar.exe" CACHE PATH "" FORCE)
SET(JAVA_MAXIMUM_HEAP_SIZE "1G" CACHE PATH "" FORCE)

SET(Java_JAR_EXECUTABLE  "C:\Program Files\Java\jdk1.6.0_14\bin\jar.exe" CACHE PATH "" FORCE)
SET(Java_JAVAC_EXECUTABLE "C:\Program Files\Java\jdk1.6.0_14\bin\javac.exe" CACHE PATH "" FORCE)
SET(Java_JAVA_EXECUTABLE "C:\Program Files\Java\jdk1.6.0_14\bin\java.exe" CACHE PATH "" FORCE)

SET(JAVADOC_EXECUTABLE "C:\Program Files\Java\jdk1.6.0_14\bin\javadoc.exe" CACHE PATH "" FORCE)