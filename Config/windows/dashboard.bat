SETLOCAL

@echo on

IF %1.==. ( echo "No arch" 
goto Fin )

set COMPILER_ARCH=%1
set OPEN_CMD_ONLY=0
set DASHBOARD_SUPERBUILD=0
set SUPERBUILD_REBUILD_OTB_ONLY=0
set DASHBOARD_PACKAGE_XDK=0
set DASHBOARD_PACKAGE_OTB=0
set CHANGE_DIR_NAMES=0

set SHOW_SHELL_ARG=%2
IF "%SHOW_SHELL_ARG%" == "SH" (
set OPEN_CMD_ONLY=1
)

set DASHBOARD_ARG=%3

IF "%DASHBOARD_ARG%" == "BUILD" (
set DASHBOARD_BUILD=0
)
IF "%DASHBOARD_ARG%" == "SUPER_BUILD" (
set DASHBOARD_SUPERBUILD=1
set SUPERBUILD_REBUILD_OTB_ONLY=1
set CHANGE_DIR_NAMES=1
)
IF "%DASHBOARD_ARG%" == "PACKAGE_OTB" (
set DASHBOARD_PACKAGE_OTB=1
)
IF "%DASHBOARD_ARG%" == "PACKAGE_XDK" (
set DASHBOARD_PACKAGE_XDK=1
)

IF %4.==. ( echo "using default branch set in dashboard.bat" ) 
set dashboard_otb_branch=%4
::default value is develop(otb_common.cmake)
IF %dashboard_otb_branch%.==. ( set dashboard_otb_branch=nightly )

IF %5.==. ( echo "using default data branch set in dashboard.bat" ) 
set dashboard_data_branch=%5
::default value is develop(otb_common.cmake)
IF %dashboard_data_branch%.==. ( set dashboard_data_branch=nightly )

IF %6.==. ( echo "default behaviour is a full build" ) 
set dashboard_remote_module=%6

:: IF %6.==. ( echo "using default cmake script dashboard.cmake" ) 
:: set DASHBOARD_SCRIPT_FILE=%6
::default value is develop(dashboard.cmake)

net use R: /delete /Y
net use R: \\otbnas.si.c-s.fr\otbdata\otb /persistent:no


set LOG_CTEST_OUTPUT_TO_FILE=0

set OMP_NUM_THREADS=1

::set dashboard_no_clean=1
::set dashboard_no_update=1
::set dashboard_no_configure=1
::set dashboard_no_test=1
::set dashboard_no_submit=1

::could be an evironment variable?
:: set CTEST_SITE=noname.no
:: set BUILD_NAME_PREFIX=Win7-vc19

set OTB_DATA_ROOT=C:\dashboard\data\otb-data
set OTB_DATA_LARGEINPUT_ROOT=R:\OTB-LargeInput
set DOWNLOAD_LOCATION=R:\DataForTests\SuperBuild-archives

::default value is Release (otb_common.cmake)
set CTEST_BUILD_CONFIGURATION=Release
set CTEST_DASHBOARD_ROOT=C:\dashboard


::see also next set PATH
:: fix the path. we don't need to care for everything existing in system path.
:: actually we shouldn't care for other things in system path.
set TOOLS_DIR=C:\Tools
set SYSPATH=C:\Windows\system32;C:\Windows
set PATH=%SYSPATH%
set PATH=%PATH%;%TOOLS_DIR%\CMake-3.5.2\bin
set PATH=%PATH%;%TOOLS_DIR%\patch-2.5.9-7\bin
set PATH=%PATH%;%TOOLS_DIR%\wget-1.11.4-1\bin
set PATH=%PATH%;%TOOLS_DIR%\Git-2.9.0\bin
set PATH=%PATH%;%TOOLS_DIR%\ninja
set PATH=%PATH%;%TOOLS_DIR%\jom\bin
set PATH=%PATH%;%TOOLS_DIR%\7zip-16.02
set PATH=%PATH%;C:\Tools\swigwin-3.0.10
set PATH=%PATH%;C:\Python27_%COMPILER_ARCH%;C:\Python27_%COMPILER_ARCH%\Scripts
::set PATH=%PATH%;%TOOLS_DIR%\coreutils-5.3.0\bin

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %COMPILER_ARCH%

::set CTEST_CMAKE_GENERATOR=Ninja
::FIXME: fix below logic.
set OTB_XDK_VERSION=5.8.0
IF "%COMPILER_ARCH%" == "x64" ( 
::set XDK_DIR_NAME=OTB-%OTB_XDK_VERSION%-win64
set XDK_FILE_NAME_WITHOUT_EXT=install_sb_x64
) ELSE (
::set XDK_FILE_NAME_WITHOUT_EXT=OTB-%OTB_XDK_VERSION%-win32
set XDK_FILE_NAME_WITHOUT_EXT=install_sb_x86
)

@echo on
IF "%CHANGE_DIR_NAMES%" == "1" ( 
set LOG_FILE_NAME=SuperBuild_win_%COMPILER_ARCH%_%dashboard_otb_branch%
set BUILD_DIR_NAME=superbuild_%COMPILER_ARCH%
set INSTALL_DIR_NAME=install_sb_%COMPILER_ARCH%
set XDK_DIR_NAME=install_sb_%COMPILER_ARCH%
set OTB_BUILD_BIN_DIR=OTB\build\bin
) ELSE ( 
set LOG_FILE_NAME=OTB_win_%COMPILER_ARCH%_%dashboard_otb_branch%
set BUILD_DIR_NAME=build_%COMPILER_ARCH%
set INSTALL_DIR_NAME=install_%COMPILER_ARCH%
set XDK_DIR_NAME=xdk\%XDK_FILE_NAME_WITHOUT_EXT%
set OTB_BUILD_BIN_DIR=bin
)

::set CTEST_BINARY_DIRECTORY=C:\sbuild\sb_build_%COMPILER_ARCH%
::set CTEST_INSTALL_DIRECTORY=C:\sbuild\sb_install_%COMPILER_ARCH%
::set XDK_INSTALL_DIR=C:\sbuild\sb_install_%COMPILER_ARCH%


IF "%XDK_INSTALL_DIR%" == "" (
set XDK_INSTALL_DIR=%CTEST_DASHBOARD_ROOT%\otb\%XDK_DIR_NAME%
)
set "CMAKE_PREFIX_PATH=%XDK_INSTALL_DIR:\=/%"

IF "%CTEST_BINARY_DIRECTORY%" == "" (
set CTEST_BINARY_DIRECTORY=%CTEST_DASHBOARD_ROOT%\otb\%BUILD_DIR_NAME%
)
IF "%CTEST_INSTALL_DIRECTORY%" == "" (
set CTEST_INSTALL_DIRECTORY=%CTEST_DASHBOARD_ROOT%\otb\%INSTALL_DIR_NAME%
)

set PATH=%PATH%;%XDK_INSTALL_DIR%\bin
set PATH=%PATH%;%XDK_INSTALL_DIR%\lib

set PATH=%PATH%;%CTEST_BINARY_DIRECTORY%\%OTB_BUILD_BIN_DIR%

::only needed if generator is Visual studio
::set PATH=%PATH%;%CTEST_BINARY_DIRECTORY%\bin\%CTEST_BUILD_CONFIGURATION%

set GDAL_DATA=%XDK_INSTALL_DIR%\data
set EPSG_CSV=%XDK_INSTALL_DIR%\share\epsg_csv
set PROJ_LIB=%XDK_INSTALL_DIR%\share

::set CMAKE_PREFIX_PATH=C:/dashboard/otb/sb_install_%COMPILER_ARCH%
:: if CTEST_CMAKE_GEN is empty, it is defined in init.bat (JOM for SuperBuild and VS 2015 for OTB)
:: if CTEST_BINARY_DIRECTORY and CTEST_INSTALL_DIRECTORY is empty, it is defined in init.bat

set OTB_CDASH_LOG_FILE=%CTEST_DASHBOARD_ROOT%\logs\%LOG_FILE_NAME%.log

IF %DASHBOARD_SCRIPT_FILE%.==. ( set DASHBOARD_SCRIPT_FILE=%CTEST_DASHBOARD_ROOT%\devutils\Config\windows\dashboard.cmake  )

IF "%OPEN_CMD_ONLY%" == "1" ( 
cd "%CTEST_DASHBOARD_ROOT%\otb"
@cmd
goto Fin)

IF "%LOG_CTEST_OUTPUT_TO_FILE%" == "1" ( 
echo "ctest output is written to %OTB_CDASH_LOG_FILE%"
ctest -C %CTEST_BUILD_CONFIGURATION% -VV -S %DASHBOARD_SCRIPT_FILE% > %OTB_CDASH_LOG_FILE% 
) ELSE ( 
ctest -C %CTEST_BUILD_CONFIGURATION% -VV -S %DASHBOARD_SCRIPT_FILE%
)

net use R: /delete /Y

::cd %CTEST_DASHBOARD_ROOT%\otb\build_%COMPILER_ARCH%\OTB\build
::ctest -R Projection

:Fin
echo "called :Fin. End of script."

EXIT

ENDLOCAL
