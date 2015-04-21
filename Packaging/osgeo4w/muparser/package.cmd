:: muparser
:: 
:: Source http://sourceforge.net/projects/muparser/files/muparser/Version%202.2.3/muparser_v2_2_3.zip/download
:: prerequisite:
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)

set CURRENT_SCRIPT_DIR=%~dp0

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=muparser
set V=2.2.3
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"

cd %W%
wget "http://sourceforge.net/projects/%P%/files/%P%/Version %V%/%P%_v2_2_3.zip/download"
if errorlevel 1 (echo Download error & goto exit)

unzip %P%_v2_2_3.zip
if errorlevel 1 (echo Unzip error & goto exit)

rename %P%_v2_2_3 "%P%-%V%"

:: build
cd %P%-%V%/build
nmake -fmakefile.vc SHARED=1
cd ../..

:: install
mkdir %P%-%V%-install\bin
mkdir %P%-%V%-install\include
mkdir %P%-%V%-install\lib

copy %P%-%V%\include\*.h "%P%-%V%-install\include"
copy %P%-%V%\lib\%P%.lib "%P%-%V%-install\lib"
copy %P%-%V%\lib\%P%.dll "%P%-%V%-install\bin"

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin include lib
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\License.txt "%R%\%P%-%V%-%B%.txt"

:exit
