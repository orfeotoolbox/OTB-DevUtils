:: ITK
:: 
:: Source :: http://sourceforge.net/projects/orfeo-toolbox/files/OTB/OTB-5.2.0/OTB-5.2.0.zip/download
:: prerequisite:
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)
::   - setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=otb
set PP=OTB
set V=5.2.0
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R2=../../release/%P%
set R=..\..\release\%P%

rmdir "%W%" /s /q
rmdir "%OSGEO4W_ROOT%\usr\src\release\%P%" /s /q

mkdir "%W%"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint.otb-bin "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint.otb-python "%W%"
copy %CURRENT_SCRIPT_DIR%orfeotoolbox-apps.bat "%W%"
copy %CURRENT_SCRIPT_DIR%otb-5.2.0-winslash.patch "%W%"

cd %W%
wget http://sourceforge.net/projects/orfeo-toolbox/files/OTB/OTB-%V%/OTB-%V%.zip/download
if errorlevel 1 (echo Download error & goto exit)

unzip %P%-%V%.zip

rename OTB-%V% "%P%-%V%"
if errorlevel 1 (echo Unzip error & goto exit)
patch -p0 < %P%-5.2.0-winslash.patch
:: build
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=OFF ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DOTB_INSTALL_APP_DIR:STRING="apps/orfeotoolbox/applications" ^
 -DOTB_INSTALL_PYTHON_DIR:STRING="otb-python/apps/orfeotoolbox/applications" ^
 -DBUILD_TESTING:BOOL=OFF ^
 -DBUILD_EXAMPLES:BOOL=OFF ^
 -DOTB_USE_CURL:BOOL=ON ^
 -DOTB_USE_MUPARSER:BOOL=ON ^
 -DOTB_USE_MUPARSERX:BOOL=ON ^
 -DOTB_USE_LIBSVM:BOOL=ON ^
 -DLIBSVM_LIBRARY:FILEPATH=%OSGEO4W_ROOT%\lib\libsvm.lib ^
 -DOTB_USE_MAPNIK:BOOL=OFF ^
 -DOTB_USE_LIBKML:BOOL=OFF ^
 -DOTB_USE_SIFTFAST:BOOL=ON ^
 -DOTB_USE_OPENCV:BOOL=ON ^
 -DOTB_USE_OPENJPEG:BOOL=OFF ^
 -DOTB_USE_QT4:BOOL=ON ^
 -DWRAP_PYTHON:BOOL=ON ^
 -DWRAP_JAVA:BOOL=ON ^
 -DCMAKE_PREFIX_PATH:PATH=%OSGEO4W_ROOT%
  
cmake --build . --config Release --target INSTALL
cd ..


:: package
mkdir %P%-%V%-install\etc
mkdir %P%-%V%-install\etc\ini
copy orfeotoolbox-apps.bat %P%-%V%-install\etc\ini\

::package otb-bin
cp setup.hint.otb-bin setup.hint
tar -C %P%-%V%-install -cjf "%R2%/otb-bin-%V%-%B%.tar.bz2" apps bin etc
tar -C ../.. -cjf "%R2%/otb-bin-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R2%/otb-bin-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R2%/otb-bin-%V%-%B%.manifest"
copy setup.hint "%R%"\setup.hint.otb-bin
copy %P%-%V%\LICENSE "%R%\otb-bin-%V%-%B%.txt"

::package otb-python
cp setup.hint.otb-python setup.hint
tar -C %P%-%V%-install/otb-python -cjf "%R2%/otb-python-%V%-%B%.tar.bz2" apps
tar -C ../.. -cjf "%R2%/otb-python-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R2%/otb-python-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R2%\otb-python-%V%-%B%.manifest"
copy setup.hint "%R%"\setup.hint.otb-python
copy %P%-%V%\LICENSE "%R%\otb-python-%V%-%B%.txt"

 cd %CURRENT_SCRIPT_DIR%
 
:exit
