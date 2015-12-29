:: ITK
:: 
:: Source :: https://www.orfeo-toolbox.org//packages/Monteverdi-3.0.0.zip
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

set P=otb-monteverdi
set PP=Monteverdi
set V=3.0.0
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

mkdir "%W%\bin"
mkdir "%W%\icons"
mkdir "%W%\etc"

xcopy /s /r %CURRENT_SCRIPT_DIR%etc "%W%\etc" /y
xcopy /s /r %CURRENT_SCRIPT_DIR%icons "%W%\icons" /y
xcopy /s /r %CURRENT_SCRIPT_DIR%bin "%W%\bin" /y

cd %W%
wget https://www.orfeo-toolbox.org/packages/%PP%-%V%.zip  --no-check-certificate
if errorlevel 1 (echo Download error & goto exit)

unzip %PP%-%V%.zip

rename "%PP%-%V%" "%P%-%V%"
if errorlevel 1 (echo Unzip error & goto exit)

:: build
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=OFF ^
 -DBUILD_TESTING:BOOL=OFF ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DMonteverdi_INSTALL_BIN_DIR:STRING="apps/orfeotoolbox/monteverdi/bin" ^
 -DOTB_DIR:PATH=%W%\..\otb\otb-5.2.0-build ^
 -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
 -DICE_INCLUDE_DIR:PATH=%W%\..\otb-ice\otb-ice-0.4.0-install\include ^
 -DICE_LIBRARY:FILEPATH=%W%\..\otb-ice\otb-ice-0.4.0-install\lib\OTBIce.lib ^
 -DCMAKE_PREFIX_PATH:PATH=%OSGEO4W_ROOT%
  
cmake --build . --config Release --target INSTALL
cd ..

::prepare install to be tarred
rmdir "%W%\%P%-%V%-install\share" /s /q
rmdir "%W%\%P%-%V%-install\lib" /s /q
rmdir "%W%\%P%-%V%-install\bin" /s /q

mkdir "%W%\%P%-%V%-install\bin"
mkdir "%W%\%P%-%V%-install\etc"
mkdir "%W%\%P%-%V%-install\apps\orfeotoolbox\monteverdi\icons"

::copy extra files
xcopy /s %W%\icons %W%\%P%-%V%-install\apps\orfeotoolbox\monteverdi\icons /y
xcopy /s %W%\bin %W%\%P%-%V%-install\bin /y
xcopy /s %W%\etc %W%\%P%-%V%-install\etc /y

::package otb-monteverdi
tar -C %P%-%V%-install -cjf "%R2%/%P%-%V%-%B%.tar.bz2" apps bin etc
tar -C ../.. -cjf "%R2%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R2%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R2%/%P%-%V%-%B%.manifest"
copy %P%-%V%\Copyright.txt "%R%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
 
:exit