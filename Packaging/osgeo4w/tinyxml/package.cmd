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

set P=tinyxml
set V=2.6.2
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"
rmdir "%W%\%P%-%V%" /s /q
rmdir "%W%\%P%-%V%-install" /s /q
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%tinyxml.sln "%W%"
copy %CURRENT_SCRIPT_DIR%tinyxml_dll.vcxproj "%W%"

cd %W%
wget http://sourceforge.net/projects/%P%/files/%P%/%V%/%P%_2_6_2.tar.gz/download
if errorlevel 1 (echo Download error & goto exit)

tar xvzf %P%_2_6_2.tar.gz
if errorlevel 1 (echo Untar error & goto exit)
rename %P% "%P%-%V%"
copy tinyxml.sln "%P%-%V%"
copy tinyxml_dll.vcxproj "%P%-%V%"

:: build
devenv %P%-%V%\%P%.sln /Build "Release|Win32" /Project tinyxml_lib.vcxproj
devenv %P%-%V%\%P%.sln /Build "Release|Win32" /Project tinyxml_dll.vcxproj

:: install
mkdir %P%-%V%-install\bin
mkdir %P%-%V%-install\include
mkdir %P%-%V%-install\lib

copy %P%-%V%\*.h "%P%-%V%-install\include"
copy %P%-%V%\Releasetinyxml\%P%.lib "%P%-%V%-install\lib"
copy %P%-%V%\Releasetinyxml_dll\%P%.dll "%P%-%V%-install\bin"

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin include lib
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/tinyxml.sln osgeo4w/%P%/tinyxml_dll.vcxproj
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
:: copy %P%-%V%\COPYING "%R%\%P%-%V%-%B%.txt"

:exit
