@echo off
:: Generate FLTK release on Windows for OSGeo4W

:: make_osgeo4w_package.bat C:\Users\jmalik\Dashboard\tools\fltk-1.3.2\src C:\Users\jmalik\Dashboard\tools\fltk-1.3.2\build-vc10 C:\Users\jmalik\Dashboard\tools\fltk-1.3.2\install x86
:: make_osgeo4w_package.bat C:\Users\jmalik\Dashboard\tools\fltk-1.3.2\src C:\Users\jmalik\Dashboard\tools\fltk-1.3.2\build-vc10-x86_64 C:\Users\jmalik\Dashboard\tools\fltk-1.3.2\install-x86_64 x86_64

set /A ARGS_COUNT=0    
for %%A in (%*) do set /A ARGS_COUNT+=1  
if %ARGS_COUNT% NEQ 4 (goto :Usage)

set FLTK_VERSION=1.3.2
set FLTK_PACKAGE_VERSION=1

if NOT DEFINED OSGEO4W_ROOT (goto :NoOSGEO4W)

set src_dir=%1
set build_dir=%2
set install_dir=%3
set arch=%4
set current_dir=%CD%

set varT=""
echo %install_dir% > %current_dir%\temp.file
sed -i "s@\\\@\\\/@g" %current_dir%\temp.file
FOR /F %%Z IN ( %current_dir%\temp.file ) DO SET install_dir_2=%%Z

del %current_dir%\temp.file

echo %install_dir_2%

echo "Config, Build and Install FLTK (%arch%) ..."

call build_fltk132-vc10.bat %src_dir% %build_dir% %install_dir% %arch% > %current_dir%\FLTK_ConfigBuildInstall_%arch%.log 2>&1


echo "Clean before packaging !"
:: Deal with FLTKConfig.cmake
sed -i "s@%install_dir_2%\/CMake@$ENV{OSGEO4W_ROOT}\/share\/FLTK@g" %install_dir%\CMake\FLTKConfig.cmake
sed -i "s@%install_dir_2%@$ENV{OSGEO4W_ROOT}@g" %install_dir%\CMake\FLTKConfig.cmake

:: Deal with UseFLTK.cmake
sed -i "s@%install_dir_2%@$ENV{OSGEO4W_ROOT}@g" %install_dir%\CMake\UseFLTK.cmake

:: Deal with FLTKLibraries-release.cmake
sed -i "s@%install_dir_2%\/lib\/fltkdll.dll@$ENV{OSGEO4W_ROOT}\/bin\/fltkdll.dll@g" %install_dir%\CMake\FLTKLibraries-release.cmake
sed -i "s@%install_dir_2%\/lib\/fltkformsdll.dll@$ENV{OSGEO4W_ROOT}\/bin\/fltkformsdll.dll@g" %install_dir%\CMake\FLTKLibraries-release.cmake
sed -i "s@%install_dir_2%\/lib\/fltkgldll.dll@$ENV{OSGEO4W_ROOT}\/bin\/fltkgldll.dll@g" %install_dir%\CMake\FLTKLibraries-release.cmake
sed -i "s@%install_dir_2%\/lib\/fltkimagesdll.dll@$ENV{OSGEO4W_ROOT}\/bin\/fltkimagesdll.dll@g" %install_dir%\CMake\FLTKLibraries-release.cmake
sed -i "s@%install_dir_2%@$ENV{OSGEO4W_ROOT}@g" %install_dir%\CMake\FLTKLibraries-release.cmake
if "%arch%" == "x86" sed -i "s@C:\/OSGeo4W@$ENV{OSGEO4W_ROOT}@g" %install_dir%\CMake\FLTKLibraries-release.cmake
if "%arch%" == "x86_64" sed -i "s@C:\/OSGeo4W64@$ENV{OSGEO4W_ROOT}@g" %install_dir%\CMake\FLTKLibraries-release.cmake
if "%arch%" == "x86_64" sed -i "s@C:\/OSGEO4~1@$ENV{OSGEO4W_ROOT}@g" %install_dir%\CMake\FLTKLibraries-release.cmake

rm %install_dir%\bin\fltk-config

mv %install_dir%\lib\fltkdll.dll %install_dir%\bin\
mv %install_dir%\lib\fltkformsdll.dll %install_dir%\bin\
mv %install_dir%\lib\fltkgldll.dll %install_dir%\bin\
mv %install_dir%\lib\fltkimagesdll.dll %install_dir%\bin\

echo "Organize before packaging !"
mkdir %install_dir%\share\FLTK
mv %install_dir%\CMake\FLTKLibraries-release.cmake %install_dir%\share\FLTK
mv %install_dir%\CMake\FLTKLibraries.cmake %install_dir%\share\\FLTK
mv %install_dir%\CMake\FLTKConfig.cmake %install_dir%\share\\FLTK
mv %install_dir%\CMake\UseFLTK.cmake %install_dir%\share\\FLTK
rm -rf %install_dir%\CMake


cd %install_dir%
mkdir ..\fltk_%arch%_package
echo "Packaging..."
tar -cjf ../fltk_%arch%_package/fltk-%FLTK_VERSION%-%FLTK_PACKAGE_VERSION%.tar.bz2 *

echo "Done !"
cd %current_dir%

goto :END

:Usage
echo You need to provide 4 arguments to the script: 
echo   1. path to the source directory
echo   2. path to the build directory (an empty directory)
echo   3. path to the installation directory (an empty directory)
echo   4. arch type (x86 or x86_64) 
GOTO :END

:NoOSGEO4W
echo You need to run this script from an OSGeo4W shell (32 or 64 bit)
GOTO :END

:END