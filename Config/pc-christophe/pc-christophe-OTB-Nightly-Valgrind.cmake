# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Fedora22-64bits-Valgrind-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 5000)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-Valgrind/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_git_url "http://git@git.orfeo-toolbox.org/git/otb.git")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")

set( dashboard_do_memcheck ON )

macro(dashboard_hook_init)
  set(CTEST_MEMORYCHECK_COMMAND /usr/bin/valgrind)
  set(CTEST_MEMORYCHECK_COMMAND_OPTIONS "--track-fds=yes --trace-children=yes --quiet --tool=memcheck --leak-check=yes --show-reachable=yes --num-callers=50 --verbose --demangle=yes --gen-suppressions=all")
  set(CTEST_MEMORYCHECK_SUPPRESSIONS_FILE ${CTEST_SOURCE_DIRECTORY}/CMake/OTBValgrind-Fedora.supp)
  set( dashboard_cache "
    BUILD_TESTING:BOOL=ON
    BUILD_EXAMPLES:BOOL=ON
    BUILD_APPLICATIONS:BOOL=ON
    
    ## ITK
    ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.10

    ## OSSIM
    OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/master/include
    OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/master/lib64/libossim.so

    ##external muparserx
    MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/stable/lib/libmuparserx.so
    MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/stable/include/muparserx

    #external openjpeg
    OpenJPEG_DIR:PATH=${INSTALLROOT}/openjpeg/stable/lib/openjpeg-2.1

    OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
    OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
    OTB_DATA_USE_LARGEINPUT:BOOL=ON

    # These options are not available anymore
    OTB_USE_PATENTED:BOOL=ON
    OTB_USE_CURL:BOOL=ON

    PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
    OTB_WRAP_PYTHON:BOOL=ON
    OTB_WRAP_JAVA:BOOL=ON

    #OTB_USE_XXX
    OTB_USE_6S=ON
    OTB_USE_CURL=ON
    OTB_USE_LIBKML=OFF
    OTB_USE_LIBSVM=ON
    OTB_USE_MAPNIK:BOOL=OFF
    OTB_USE_MUPARSER:BOOL=ON
    OTB_USE_MUPARSERX:BOOL=ON
    OTB_USE_OPENCV:BOOL=ON
    OTB_USE_OPENJPEG=ON
    OTB_USE_QT4=ON
    OTB_USE_SIFTFAST=ON

    MEMORYCHECK_COMMAND:FILEPATH=${CTEST_MEMORYCHECK_COMMAND}
    MEMORYCHECK_COMMAND_OPTIONS:STRING=${CTEST_MEMORYCHECK_COMMAND_OPTIONS}
    MEMORYCHECK_SUPPRESSIONS_FILE:FILEPATH=${CTEST_MEMORYCHECK_SUPPRESSIONS_FILE}
    "
    )
endmacro(dashboard_hook_init)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
