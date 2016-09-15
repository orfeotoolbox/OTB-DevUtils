#!/usr/bin/python3
#
# Copyright (C) 2016 by Centre National d'Etudes Spatiales (CNES)
#
# Author: Sebastien DINOT <sebastien.dinot@c-s.fr>
#

import os, sys, re, copy



def replaceHeader(filename, oldHeader, newHeader):

    sourceFile = open(filename)
    sourceContent = sourceFile.read().lstrip()
    sourceFile.close()
    newHeaderWithBlankLine = newHeader + "\n"

    targetContent = sourceContent.replace(oldHeader, newHeaderWithBlankLine)
    if targetContent != sourceContent:
        print("UPDATED: {0}".format(filename))
        os.remove(filename)
        sourceFile = open(filename, 'w')
        sourceFile.write(targetContent)
        sourceFile.close()
        return True
    else:
        return False



def addHeader(filename, newHeader):

    sourceFile = open(filename)
    sourceContent = sourceFile.read().lstrip()
    sourceFile.close()

    newHeaderWithBlankLine = newHeader + "\n"

    targetContent = newHeaderWithBlankLine + sourceContent
    print("ADDED: {0}".format(filename))
    os.remove(filename)
    sourceFile = open(filename, 'w')
    sourceFile.write(targetContent)
    sourceFile.close()
    return True


topdir = 'otb'
hdrdir = 'headers'


# Files to be ignored
op_type_1 = [
    '.travis.yml',
    '.hgignore',
    '.gitignore',
    '.hgsigs',
    'CMake/CppcheckTargets.cmake',
    'CMake/FindKWStyle.cmake',
    'CMake/FindLibSVM.cmake',
    'CMake/Findcppcheck.cmake',
    'CMake/OTB_CheckCCompilerFlag.cmake',
    'CMake/TopologicalSort.cmake',
    'CMake/UseJava.cmake',
    'CMake/UseJavaClassFilelist.cmake',
    'CMake/UseJavaSymlinks.cmake',
    'CMake/UseSWIGLocal.cmake',
    'Modules/Adapters/OSSIMAdapters/test/otbPlatformPositionAdapter.cxx',
    'Modules/ThirdParty/ITK/include/itkImageRegionMultidimensionalSplitter.h',
    'Modules/ThirdParty/ITK/include/itkImageRegionMultidimensionalSplitter.hxx',
    'Modules/ThirdParty/ITK/include/itkImageRegionSplitter.h',
    'Modules/ThirdParty/ITK/include/itkImageRegionSplitter.hxx',
    'Modules/ThirdParty/ITK/include/itkTransformToDisplacementFieldSource.h',
    'Modules/ThirdParty/ITK/include/itkTransformToDisplacementFieldSource.hxx',
    'Modules/ThirdParty/ITK/include/itkUnaryFunctorImageFilter.h',
    'Modules/ThirdParty/ITK/include/itkUnaryFunctorImageFilter.hxx',
    'Modules/ThirdParty/SPTW/src/examples/test.cpp',
    'Modules/ThirdParty/SPTW/src/sptw.cc',
    'Modules/ThirdParty/SPTW/src/sptw.h',
    'Modules/ThirdParty/SPTW/src/utils.h',
    'Modules/ThirdParty/SiftFast/src/FindBoost.cmake',
    'Modules/ThirdParty/SiftFast/src/libsiftfast.cpp',
    'Modules/ThirdParty/SiftFast/src/makerelease.sh',
    'Modules/ThirdParty/SiftFast/src/profiler.cpp',
    'Modules/ThirdParty/SiftFast/src/profiler.h',
    'Modules/ThirdParty/SiftFast/src/runcmake.bat',
    'Modules/ThirdParty/SiftFast/src/siftfast.cpp',
    'Modules/ThirdParty/SiftFast/src/siftfast.h',
    'Modules/ThirdParty/SiftFast/src/siftfast.m',
    'Modules/ThirdParty/SiftFast/src/siftfastpy.cpp',
    'Modules/ThirdParty/SiftFast/src/siftmex.cpp',
    'Modules/ThirdParty/SiftFast/src/test_try_compile_libsiftfast.cpp',
    'Modules/Wrappers/SWIG/src/numpy.i',
    'Utilities/Maintenance/BuildHeaderTest.py'
]


op_type_2 = [
    {
        'files' : [ 'Modules/Feature/Corner/include/otbLineSpatialObjectListToRightAnglePointSetFilter.h',
                    'Modules/Feature/Density/include/otbKeyPointDensityImageFilter.h',
                    'Modules/Feature/Density/include/otbKeyPointDensityImageFilter.txx',
                    'Modules/Feature/Density/include/otbPointSetToDensityImageFilter.h',
                    'Modules/Feature/Density/include/otbPointSetToDensityImageFilter.txx',
                    'Modules/Feature/Descriptors/include/otbImageToHessianDeterminantImageFilter.h',
                    'Modules/Feature/Descriptors/include/otbImageToHessianDeterminantImageFilter.txx',
                    'Modules/Feature/Descriptors/include/otbImageToSURFKeyPointSetFilter.h',
                    'Modules/Feature/Descriptors/include/otbImageToSURFKeyPointSetFilter.txx',
                    'Modules/Feature/Descriptors/test/otbImageToSURFKeyPointSetFilterNew.cxx',
                    'Modules/Feature/Descriptors/test/otbImageToSURFKeyPointSetFilterOutputDescriptorAscii.cxx',
                    'Modules/Feature/Descriptors/test/otbImageToSURFKeyPointSetFilterOutputInterestPointAscii.cxx',
                    'Modules/Feature/Edge/include/otbEdgeDensityImageFilter.h',
                    'Modules/Feature/Edge/include/otbEdgeDensityImageFilter.txx',
                    'Modules/Feature/Edge/include/otbEdgeDetectorImageFilter.h',
                    'Modules/Feature/Edge/include/otbEdgeDetectorImageFilter.txx',
                    'Modules/Filtering/ImageManipulation/include/otbBinaryImageDensityFunction.h',
                    'Modules/Filtering/ImageManipulation/include/otbBinaryImageDensityFunction.txx',
                    'Modules/Filtering/ImageManipulation/include/otbThresholdVectorImageFilter.h',
                    'Modules/Filtering/ImageManipulation/include/otbThresholdVectorImageFilter.txx',
                    'Modules/Filtering/ImageManipulation/test/otbClampImageFilter.cxx',
                    'Modules/Filtering/ImageManipulation/test/otbClampVectorImageFilter.cxx',
                    'Modules/Filtering/ImageManipulation/test/otbThresholdVectorImageFilter.cxx',
                    'Modules/Filtering/Projection/include/otbGeographicalDistance.h',
                    'Modules/Filtering/Projection/include/otbGeographicalDistance.txx',
                    'Modules/Filtering/Projection/include/otbGroundSpacingImageFunction.h',
                    'Modules/Filtering/Projection/include/otbGroundSpacingImageFunction.txx' ],
        'old' :   [ 'header_cecill_cpp.60', 'header_cecill_cpp.61', 'header_cecill_cpp.62' ],
        'new' :   'header_apache_cpp.01'
    },
    {
        'files' : [ 'Modules/Wrappers/SWIG/src/otbApplication.i',
                    'Modules/Wrappers/SWIG/src/otbWrapperSWIGIncludes.h',
                    'Modules/Wrappers/SWIG/src/Python.i',
                    'Modules/Wrappers/SWIG/src/PyCommand.i',
                    'Modules/Wrappers/SWIG/src/Java.i',
                    'Modules/Wrappers/SWIG/src/Lua.i',
                    'Modules/Wrappers/SWIG/src/Ruby.i',
                    'Modules/Wrappers/SWIG/src/itkBase.i',
                    'Modules/Wrappers/SWIG/src/itkBase.includes',
                    'Modules/Wrappers/SWIG/src/itkMacro.i' ],
        'old' :   [ 'header_cecill_cpp.70', 'header_cecill_cpp.71' ],
        'new' :   'header_apache_cpp.04'
    },
    {
        'files' : [ 'Modules/Wrappers/SWIG/src/CMakeLists.txt', ],
        'old' :   [ 'header_cecill_cmake.01', ],
        'new' :   'header_apache_cmake.01'
    },
    {
        'files' : [ 'Modules/Wrappers/SWIG/test/python/PythonNewStyleParametersTest.py',
                    'Modules/Wrappers/SWIG/test/python/PythonNumpyTest.py' ],
        'old' :   [ 'header_cecill_python.01', 'header_cecill_python.02' ],
        'new' :   'header_apache_python.02'
    },
]



op_type_3 = [
    {
        'files' : [ 'Modules/Wrappers/SWIG/otb-module-init.cmake',
                    'Modules/Wrappers/SWIG/test/python/CMakeLists.txt' ],
        'new' :   'header_apache_cmake.01'
    },
    {
        'files' : [ 'Modules/Core/Common/src/otbConfigure.h.in',
                    'Modules/Core/Metadata/include/otbSarCalibrationLookupData.h',
                    'Modules/Filtering/ImageNoise/include/otbNoiseEstimatorVectorImageFilter.h',
                    'Modules/Filtering/Statistics/test/StreamingStat.cxx',
                    'Modules/Hyperspectral/AnomalyDetection/test/otbLocalRxDetectorRoiTest.cxx',
                    'Modules/Hyperspectral/AnomalyDetection/test/otbLocalRxDetectorTest.cxx',
                    'Modules/IO/TestKernel/include/otbDifferenceImageFilter.h',
                    'Modules/IO/TestKernel/include/otbDifferenceImageFilter.txx',
                    'Modules/ThirdParty/Curl/CMake/otbTestCurlMulti.cxx',
                    'Modules/ThirdParty/GDAL/gdalCreateCopyTest.cxx',
                    'Modules/ThirdParty/GDAL/gdalCreateTest.cxx',
                    'Modules/ThirdParty/GDAL/gdalFormatsListTest.c',
                    'Modules/ThirdParty/GDAL/gdalFormatsTest.c',
                    'Modules/ThirdParty/GDAL/gdalOGRTest.cxx',
                    'Modules/ThirdParty/GDAL/gdalSymbolsTest.cxx',
                    'Modules/ThirdParty/GDAL/gdalVersionTest.cxx',
                    'Modules/ThirdParty/MuParser/CMake/otbTestMuParserHasCxxLogicalOperators.cxx',
                    'Modules/ThirdParty/TinyXML/CMake/otbTestTinyXMLUseSTL.cxx',
                    'Modules/Visualization/Ice/include/otbNonOptGlImageActor.h',
                    'Modules/Visualization/Ice/src/otbNonOptGlImageActor.cxx',
                    'Modules/Visualization/MonteverdiCore/src/ConfigureMonteverdi.h.in',
                    'Modules/Wrappers/ApplicationEngine/include/otbWrapperInputProcessXMLParameter.h',
                    'Modules/Wrappers/ApplicationEngine/include/otbWrapperOutputProcessXMLParameter.h',
                    'Modules/Wrappers/ApplicationEngine/src/otbWrapperInputProcessXMLParameter.cxx',
                    'Modules/Wrappers/ApplicationEngine/src/otbWrapperOutputProcessXMLParameter.cxx',
                    'Modules/Wrappers/SWIG/test/java/JavaSmoothingTest.java',
                    'Modules/Wrappers/SWIG/test/java/JavaRescaleInXMLTest.java',
                    'Modules/Wrappers/SWIG/test/java/JavaRescaleOutXMLTest.java',
                    'Modules/Wrappers/SWIG/test/java/JavaRescaleTest.java'
        ],
        'new' :   'header_apache_cpp.01'
    },
    {
        'files' : [ 'Modules/Wrappers/SWIG/test/python/Bug440.py',
                    'Modules/Wrappers/SWIG/test/python/Bug736.py',
                    'Modules/Wrappers/SWIG/test/python/Bug804.py',
                    'Modules/Wrappers/SWIG/test/python/Bug823.py',
                    'Modules/Wrappers/SWIG/test/python/PythonConnectApplications.py',
                    'Modules/Wrappers/SWIG/test/python/PythonHyperspectralUnmixing1.py',
                    'Modules/Wrappers/SWIG/test/python/PythonInXMLTest.py',
                    'Modules/Wrappers/SWIG/test/python/PythonNewStyleParametersInstanciateAllTest.py',
                    'Modules/Wrappers/SWIG/test/python/PythonOutXMLTest.py',
                    'Modules/Wrappers/SWIG/test/python/PythonRescaleTest.py',
                    'Modules/Wrappers/SWIG/test/python/PythonSmoothingTest.py',
                    'Modules/Wrappers/SWIG/test/python/PythonTestDriver.py'
        ],
        'new' :   'header_apache_python.01'
    },
]



op_type_4 = [
    {
        'pattern' : '^.*/(CMakeLists\\.txt|.*\\.cmake(\\.in)?)$',
        'exclude' : [ 'CMake/CppcheckTargets.cmake',
                      'CMake/Findcppcheck.cmake',
                      'CMake/FindGLEW.cmake',
                      'CMake/FindKWStyle.cmake',
                      'CMake/FindLibSVM.cmake',
                      'CMake/FindOpenThreads.cmake',
                      'CMake/OTB_CheckCCompilerFlag.cmake',
                      'CMake/TopologicalSort.cmake',
                      'CMake/UseJava.cmake',
                      'CMake/UseJavaClassFilelist.cmake',
                      'CMake/UseJavaSymlinks.cmake',
                      'CMake/UseSWIGLocal.cmake',
                      'Modules/Remote/otbGRM.remote.cmake',
                      'Modules/Remote/Mosaic.remote.cmake',
                      'Modules/Remote/SertitObject.remote.cmake',
                      'Modules/ThirdParty/SiftFast/src/FindBoost.cmake',
                      'Modules/Wrappers/SWIG/otb-module-init.cmake',
                      'Modules/Wrappers/SWIG/test/python/CMakeLists.txt'
        ],
        'new' :     'header_apache_cmake.02'
    },
]



op_type_5 = [
    {
        'ext' : [ '.cxx', '.hxx', '.txx', '.cpp', '.hpp', '.cc', '.hh', '.c', '.h',
                  '.in', '.includes', '.i', '.inc' ],
        'old' : [ 'header_cecill_cpp.01', 'header_cecill_cpp.02', 'header_cecill_cpp.03',
                  'header_cecill_cpp.04', 'header_cecill_cpp.05', 'header_cecill_cpp.06',
                  'header_cecill_cpp.07', 'header_cecill_cpp.08', 'header_cecill_cpp.09',
                  'header_cecill_cpp.10', 'header_cecill_cpp.11', 'header_cecill_cpp.12',
                  'header_cecill_cpp.13', 'header_cecill_cpp.14', 'header_cecill_cpp.15',
                  'header_cecill_cpp.16', 'header_cecill_cpp.17', 'header_cecill_cpp.18',
                  'header_cecill_cpp.19', 'header_cecill_cpp.20', 'header_cecill_cpp.21',
                  'header_cecill_cpp.22', 'header_cecill_cpp.23', 'header_cecill_cpp.24',
                  'header_cecill_cpp.25', 'header_cecill_cpp.26', 'header_cecill_cpp.27' ],
        'new' : 'header_apache_cpp.01'
    },
    {
        'ext' : [ '.cxx', '.hxx', '.txx', '.cpp', '.hpp', '.cc', '.hh', '.c', '.h',
                  '.in', '.includes', '.i' ],
        'old' : [ 'header_cecill_cpp.30', 'header_cecill_cpp.31', 'header_cecill_cpp.32',
                  'header_cecill_cpp.33', 'header_cecill_cpp.34', 'header_cecill_cpp.35',
                  'header_cecill_cpp.36', 'header_cecill_cpp.37' ],
        'new' : 'header_apache_cpp.02'
    },
    {
        'ext' : [ '.cxx', '.hxx', '.txx', '.cpp', '.hpp', '.cc', '.hh', '.c', '.h', '.in',
                  '.includes', '.i' ],
        'old' : [ 'header_cecill_cpp.40', 'header_cecill_cpp.41', 'header_cecill_cpp.42',
                  'header_cecill_cpp.43', 'header_cecill_cpp.44', 'header_cecill_cpp.45',
                  'header_cecill_cpp.46', 'header_cecill_cpp.47', 'header_cecill_cpp.48',
                  'header_cecill_cpp.49', 'header_cecill_cpp.50' ],
        'new' : 'header_apache_cpp.03'
    },
    {
        'ext' : [ '.cxx', '.txx', '.h' ],
        'old' : [ 'header_cecill_cpp.80' ],
        'new' : 'header_apache_cpp.05'
    },
    {
        'ext' : [ '.cxx', '.txx', '.h' ],
        'old' : [ 'header_cecill_cpp.81', 'header_cecill_cpp.82' ],
        'new' : 'header_apache_cpp.07'
    },
    {
        'ext' : [ '.cxx', '.txx', '.h' ],
        'old' : [ 'header_cecill_cpp.83' ],
        'new' : 'header_apache_cpp.08'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.01', 'header_lgpl_cpp.04', 'header_lgpl_cpp.05',
                  'header_lgpl_cpp.06', 'header_lgpl_cpp.08', 'header_lgpl_cpp.09',
                  'header_lgpl_cpp.10', 'header_lgpl_cpp.11', 'header_lgpl_cpp.12',
                  'header_lgpl_cpp.13', 'header_lgpl_cpp.15', 'header_lgpl_cpp.21',
                  'header_lgpl_cpp.22', 'header_lgpl_cpp.27'],
        'new' : 'header_mit_cpp.01'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.03' ],
        'new' : 'header_mit_cpp.02'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.02', 'header_lgpl_cpp.07', 'header_lgpl_cpp.17',
                  'header_lgpl_cpp.18', 'header_lgpl_cpp.24', 'header_lgpl_cpp.25',
                  'header_lgpl_cpp.26', 'header_lgpl_cpp.29', 'header_lgpl_cpp.30' ],
        'new' : 'header_mit_cpp.03'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.16', 'header_lgpl_cpp.19', 'header_lgpl_cpp.31' ],
        'new' : 'header_mit_cpp.04'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.14' ],
        'new' : 'header_mit_cpp.05'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.20' ],
        'new' : 'header_mit_cpp.06'
    },
    {
        'ext' : [ '.cpp', '.h', '.in' ],
        'old' : [ 'header_lgpl_cpp.23' ],
        'new' : 'header_mit_cpp.07'
    },
    {
        'ext' : [ '.cxx' ],
        'old' : [ 'header_none_cpp.01' ],
        'new' : 'header_apache_cpp.06'
    },
]



otbfiles = []

pattern1 = re.compile('^(CMakeLists\\.txt|.*\\.cmake(\\.in)?)$')
pattern2 = re.compile('((README|VERSION|LICENS|AUTHORS|RELEASE|INSTALL|NOTES|Makefile-upstream).*|'
                      + '.*\\.(png|ico|dox|html|desktop|ts|xpm|ui|qrc|svg|orig|icns|rc.in|dox.in|config.in|css))$')
for root, dirs, files in os.walk(topdir, topdown=True):
    if '.git' in dirs:
        dirs.remove('.git')

    if 'Documentation' in dirs:
        dirs.remove('Documentation')

    if 'Copyright' in dirs:
        dirs.remove('Copyright')

    if (root.find('/SuperBuild/patches') != -1) or (root.find('/6S') != -1):
        for fn in files:
            if pattern1.match(fn):
                filename = os.path.join(root, fn)
                if os.path.isfile(filename):
                    otbfiles.append(filename)
    else:
        for fn in files:
            if not pattern2.match(fn):
                filename = os.path.join(root, fn)
                if os.path.isfile(filename):
                    otbfiles.append(filename)
            else:
                print("EXCLUDED: {0}".format(fn))

#for fn in otbfiles:
#    print(fn)
#exit(1)



# NB: L'instruction "otbfiles1 = otbfiles" ne copie pas la liste mais cree une
# reference vers la liste. Or, ici, on veut reellement copier la liste car les
# deux doivent evoluer separement. Du coup, il faut utiliser la fonction
# copy.copy(), voire la fonction copy.deepcopy() pour proprement copier les
# objets en profondeur.
otbfiles1 = copy.deepcopy(otbfiles)

for fn in op_type_1:
    filename = os.path.join(topdir, fn)
    otbfiles1.remove(filename)
    print("REMOVED: {0}".format(fn))



otbfiles2 = copy.deepcopy(otbfiles1)

for op in op_type_2:

    newHeaderFile = open(os.path.join(hdrdir, op['new']))
    newHeader     = newHeaderFile.read()

    for fn in op['files']:

        for old in op['old']:

            oldHeaderFile = open(os.path.join(hdrdir, old))
            oldHeader     = oldHeaderFile.read()
            filename = os.path.join(topdir, fn)
            if os.path.isfile(filename) and filename in otbfiles2:
                if replaceHeader(filename, oldHeader, newHeader):
                    otbfiles2.remove(filename)



for op in op_type_3:

    newHeaderFile = open(os.path.join(hdrdir, op['new']))
    newHeader     = newHeaderFile.read()

    for fn in op['files']:

        filename = os.path.join(topdir, fn)
        if os.path.isfile(filename) and filename in otbfiles2:
            addHeader(filename, newHeader)
            otbfiles2.remove(filename)



otbfiles3 = copy.deepcopy(otbfiles2)

for op in op_type_4:

    newHeaderFile = open(os.path.join(hdrdir, op['new']))
    newHeader     = newHeaderFile.read()

    pattern = re.compile(op['pattern'])

    excluded = []
    for i, e in enumerate(op['exclude']):
        excluded.append(os.path.join(topdir, e))

    for fn in otbfiles2:
        if pattern.match(fn) and fn in otbfiles3 and fn not in excluded:
                addHeader(fn, newHeader)
                otbfiles3.remove(fn)



otbfiles4 = copy.deepcopy(otbfiles3)

for op in op_type_5:

    newHeaderFile = open(os.path.join(hdrdir, op['new']))
    newHeader     = newHeaderFile.read()

    for ext in op['ext']:

        for old in op['old']:
            oldHeaderFile = open(os.path.join(hdrdir, old))
            oldHeader     = oldHeaderFile.read()

            for fn in otbfiles3:
                # splitext(file) renvoie l'extension avec le "." de separation
                if ext == os.path.splitext(fn)[1]:
                    if os.path.isfile(fn) and fn in otbfiles4:
                        if replaceHeader(fn, oldHeader, newHeader):
                            otbfiles4.remove(fn)



for fn in otbfiles4:
    print("NOT PROCESSED: {0}".format(fn))
