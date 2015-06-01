:: tinyXML
:: 
:: Source http://sourceforge.net/projects/tinyxml/files/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz/download
:: prerequisite:
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=itk
set SV=4.7
set V=4.7.2
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"
rmdir "%W%\%P%-%V%" /s /q
rmdir "%W%\%P%-%V%-install" /s /q
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"

cd %W%
wget http://sourceforge.net/projects/%P%/files/%P%/%SV%/InsightToolkit-%V%.tar.gz/download
if errorlevel 1 (echo Download error & goto exit)

tar xvzf InsightToolkit-%V%.tar.gz
if errorlevel 1 (echo Untar error & goto exit)

::delete unused .ExternalData
rmdir /s /q InsightToolkit-%V%\.ExternalData

rename InsightToolkit-%V% "%P%-%V%"

:: build
mkdir "%P%-%V%-build" /s /q

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=OFF ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DITK_BUILD_DEFAULT_MODULES:BOOL=OFF ^
    -DModule_ITKCommon:BOOL=ON ^
    -DModule_ITKFiniteDifference:BOOL=ON ^
    -DModule_ITKGPUCommon:BOOL=ON ^
    -DModule_ITKGPUFiniteDifference:BOOL=ON ^
    -DModule_ITKImageAdaptors:BOOL=ON ^
    -DModule_ITKImageFunction:BOOL=ON ^
    -DModule_ITKMesh:BOOL=ON ^
    -DModule_ITKQuadEdgeMesh:BOOL=ON ^
    -DModule_ITKSpatialObjects:BOOL=ON ^
    -DModule_ITKTransform:BOOL=ON ^
    -DModule_ITKAnisotropicSmoothing:BOOL=ON ^
    -DModule_ITKAntiAlias:BOOL=ON ^
    -DModule_ITKBiasCorrection:BOOL=ON ^
    -DModule_ITKBinaryMathematicalMorphology:BOOL=ON ^
    -DModule_ITKColormap:BOOL=ON ^
    -DModule_ITKConvolution:BOOL=ON ^
    -DModule_ITKCurvatureFlow:BOOL=ON ^
    -DModule_ITKDeconvolution:BOOL=ON ^
    -DModule_ITKDenoising:BOOL=ON ^
    -DModule_ITKDisplacementField:BOOL=ON ^
    -DModule_ITKDistanceMap:BOOL=ON ^
    -DModule_ITKFastMarching:BOOL=ON ^
    -DModule_ITKFFT:BOOL=ON ^
    -DModule_ITKGPUAnisotropicSmoothing:BOOL=ON ^
    -DModule_ITKGPUImageFilterBase:BOOL=ON ^
    -DModule_ITKGPUSmoothing:BOOL=ON ^
    -DModule_ITKGPUThresholding:BOOL=ON ^
    -DModule_ITKImageCompare:BOOL=ON ^
    -DModule_ITKImageCompose:BOOL=ON ^
    -DModule_ITKImageFeature:BOOL=ON ^
    -DModule_ITKImageFilterBase:BOOL=ON ^
    -DModule_ITKImageFusion:BOOL=ON ^
    -DModule_ITKImageGradient:BOOL=ON ^
    -DModule_ITKImageGrid:BOOL=ON ^
    -DModule_ITKImageIntensity:BOOL=ON ^
    -DModule_ITKImageLabel:BOOL=ON ^
    -DModule_ITKImageSources:BOOL=ON ^
    -DModule_ITKImageStatistics:BOOL=ON ^
    -DModule_ITKLabelMap:BOOL=ON ^
    -DModule_ITKMathematicalMorphology:BOOL=ON ^
    -DModule_ITKPath:BOOL=ON ^
    -DModule_ITKQuadEdgeMeshFiltering:BOOL=ON ^
    -DModule_ITKSmoothing:BOOL=ON ^
    -DModule_ITKSpatialFunction:BOOL=ON ^
    -DModule_ITKThresholding:BOOL=ON ^
    -DModule_ITKEigen:BOOL=ON ^
    -DModule_ITKNarrowBand:BOOL=ON ^
    -DModule_ITKNeuralNetworks:BOOL=ON ^
    -DModule_ITKOptimizers:BOOL=ON ^
    -DModule_ITKOptimizersv4:BOOL=ON ^
    -DModule_ITKPolynomials:BOOL=ON ^
    -DModule_ITKStatistics:BOOL=ON ^
    -DModule_ITKRegistrationCommon:BOOL=ON ^
    -DModule_ITKGPURegistrationCommon:BOOL=ON ^
    -DModule_ITKGPUPDEDeformableRegistration:BOOL=ON ^
    -DModule_ITKMetricsv4:BOOL=ON ^
    -DModule_ITKPDEDeformableRegistration:BOOL=ON ^
    -DModule_ITKRegistrationMethodsv4:BOOL=ON ^
    -DModule_ITKClassifiers:BOOL=ON ^
    -DModule_ITKConnectedComponents:BOOL=ON ^
    -DModule_ITKDeformableMesh:BOOL=ON ^
    -DModule_ITKKLMRegionGrowing:BOOL=ON ^
    -DModule_ITKLabelVoting:BOOL=ON ^
    -DModule_ITKLevelSets:BOOL=ON ^
    -DModule_ITKLevelSetsv4:BOOL=ON ^
    -DModule_ITKMarkovRandomFieldsClassifiers:BOOL=ON ^
    -DModule_ITKRegionGrowing:BOOL=ON ^
    -DModule_ITKSignedDistanceFunction:BOOL=ON ^
    -DModule_ITKVoronoi:BOOL=ON ^
    -DModule_ITKWatersheds:BOOL=ON ^
  -DITKGroup_Core:BOOL=OFF ^
 -DBUILD_TESTING:BOOL=OFF ^
 -DBUILD_EXAMPLES:BOOL=OFF ^
 -DITK_USE_SYSTEM_EXPAT:BOOL=ON ^
 -DITK_USE_SYSTEM_ZLIB:BOOL=ON ^
 -DITK_USE_SYSTEM_TIFF:BOOL=ON ^
 -DITK_USE_SYSTEM_PNG:BOOL=ON ^
 -DITK_USE_SYSTEM_FFTW:BOOL=ON ^
 -DUSE_FFTWF:BOOL=ON ^
 -DUSE_FFTWD:BOOL=ON ^
 -DFFTW_INCLUDE_PATH:PATH=%OSGEO4W_ROOT%/include ^
 -DFFTWF_LIB:FILEPATH=%OSGEO4W_ROOT%/lib/fftw3.lib ^
 -DFFTWD_LIB:FILEPATH=%OSGEO4W_ROOT%/lib/fftw3.lib ^
 -DTIFF_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DTIFF_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/libtiff_i.lib ^
 -DEXPAT_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DEXPAT_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/libexpat.lib ^
 -DPNG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include/libpng16 ^
 -DPNG_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/libpng16.lib ^
 -DZLIB_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DZLIB_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/zlib.lib

cmake --build . --config Release --target INSTALL
cd ..


:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" include lib share
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
 copy %P%-%V%\LICENSE "%R%\%P%-%V%-%B%.txt"

:exit
