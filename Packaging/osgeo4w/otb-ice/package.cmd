:: ITK
:: 
:: Source :: https://www.orfeo-toolbox.org/packages/Ice-0.4.0.zip
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

set P=otb-ice
set PP=Ice
set V=0.4.0
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R2=../../release/%P%
set R=..\..\release\%P%

rmdir "%W%" /s /q
rmdir "%OSGEO4W_ROOT%\usr\src\release\%P%" /s /q

mkdir "%W%"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"


cd %W%
wget https://www.orfeo-toolbox.org/packages/%PP%-%V%.zip --no-check-certificate
if errorlevel 1 (echo Download error & goto exit)

unzip %PP%-%V%.zip

rename %PP%-%V% "%P%-%V%"
if errorlevel 1 (echo Unzip error & goto exit)
:: build
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=OFF ^
 -DGLEW_LIBRARY:FILEPATH=%OSGEO4W_ROOT%\lib\glew32.lib ^
 -DIce_INSTALL_BIN_DIR:STRNG="apps/orfeotoolbox/ice/bin" ^
 -DOTB_DIR:PATH=%W%\..\otb\otb-5.2.0-build ^
 -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DCMAKE_PREFIX_PATH:PATH=%OSGEO4W_ROOT%
  
cmake --build . --config Release --target INSTALL
cd ..

::package otb-ice
tar -C %P%-%V%-install -cjf "%R2%/%P%-%V%-%B%.tar.bz2" apps
tar -C ../.. -cjf "%R2%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R2%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R2%/%P%-%V%-%B%.manifest"
copy %P%-%V%\Copyright.txt "%R%\%P%-%V%-%B%.txt"

 cd %CURRENT_SCRIPT_DIR%
 
:exit
