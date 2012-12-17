@rem generate OpenJPEG release on Windows for OSGeo4W

set OPJ_TAG=version.2.0
set OPJ_VERSION=2.0.0
set OPJ_PACKAGE_VERSION=1

set LANG=C
call "C:\OSGeo4W\bin\o4w_env.bat"
call "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools\vsvars32.bat"
set TMPDIR=%TMP%\openjpeg_release

cd %TMP%
rm -rf %TMPDIR%
mkdir %TMPDIR%
cd %TMPDIR%
echo "Checkout..."
svn checkout -q https://openjpeg.googlecode.com/svn/tags/%OPJ_TAG% openjpeg > svn.log 2>&1

mkdir %TMPDIR%\openjpeg-build
mkdir %TMPDIR%\openjpeg-install

@rem configure openjpeg. BUILD_THIRDPARTY to ON for LCMS2
cd %TMPDIR%\openjpeg-build
echo "Configuration..."
cmake -G "Visual Studio 9 2008" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DCMAKE_INSTALL_PREFIX:STRING="../openjpeg-install" ^
 -DBUILD_JPWL:BOOL=OFF ^
 -DBUILD_MJ2:BOOL=OFF ^
 -DBUILD_JPIP:BOOL=OFF ^
 -DBUILD_JAVA:BOOL=OFF ^
 -DTIFF_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DTIFF_LIBRARY:PATH=%OSGEO4W_ROOT%/lib/libtiff_i.lib ^
 -DPNG_PNG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include/libpng12 ^
 -DPNG_LIBRARY:PATH=%OSGEO4W_ROOT%/lib/libpng13.lib ^
 -DZLIB_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DZLIB_LIBRARY:PATH=%OSGEO4W_ROOT%/lib/zlib.lib ^
 ..\openjpeg > config.log 2>&1

@rem build openjpeg
echo "Build & Install..."
cmake --build . --config Release --target INSTALL > install.log 2>&1

cd %TMPDIR%\openjpeg-install
echo "Packaging..."
rm %TMPDIR%\openjpeg-install\bin\Microsoft.VC90.CRT.manifest
rm %TMPDIR%\openjpeg-install\bin\msvc*.dll
tar -cjf ../openjpeg-%OPJ_VERSION%-%OPJ_PACKAGE_VERSION%.tar.bz2 *

echo "Done !"
cd 