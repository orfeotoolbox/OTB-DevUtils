SETLOCAL

@echo off

IF %1.==. ( echo "No arch" 
goto Fin )

set COMPILER_ARCH=%1
set DROP_SHELL=0
set DASHBOARD_SUPERBUILD=0
set DASHBOARD_PKG=0
set DASHBOARD_ARG2_OK=0
set DASHBOARD_ARG3_OK=0
set WITH_REMOTE_MODULES=0

set SHOW_CMD_ARG=%2
IF "%SHOW_CMD_ARG%" == "CMD" (
set DROP_SHELL=1
set DASHBOARD_ARG2_OK=1
)
IF "%SHOW_CMD_ARG%" == "0" (
set DROP_SHELL=0
set DASHBOARD_ARG2_OK=1
)

set DASHBOARD_ACTION=%3

IF "%DASHBOARD_ACTION%" == "BUILD" (
set DASHBOARD_BUILD=0
set DASHBOARD_ARG3_OK=1
)

IF "%DASHBOARD_ACTION%" == "SUPER_BUILD" (
set DASHBOARD_SUPERBUILD=1
set DASHBOARD_ARG3_OK=1
:: RK: disable remote modules temporarily
:: currently mosaic, ffsforgmm, sertitobject build OK
:: problem is evident only using cmake 3.10 and export all symbols off
set WITH_REMOTE_MODULES=0
)

IF "%DASHBOARD_ACTION%" == "PKG" (
set DASHBOARD_PKG=1
set DASHBOARD_ARG3_OK=1
)

IF "%DASHBOARD_ARG3_OK%" == "0" (
echo "unknown argument '%DASHBOARD_ACTION%'" 
goto Fin
)

IF "%DASHBOARD_ARG2_OK%" == "0" (
echo "unknown argument '%SHOW_CMD_ARG%'" 
goto Fin
)
IF %4.==. ( echo "using default branch set in dashboard.bat" ) 
set dashboard_otb_branch=%4
::default value is develop(otb_common.cmake)
IF %dashboard_otb_branch%.==. ( set dashboard_otb_branch=nightly)

IF %5.==. ( echo "using default data branch set in dashboard.bat" ) 
set dashboard_data_branch=%5
::default value is develop(otb_common.cmake)
IF %dashboard_data_branch%.==. ( set dashboard_data_branch=nightly)

IF %6.==. ( echo "default behaviour is a full build" ) 
set dashboard_remote_module=%6

@echo on
:: IF %6.==. ( echo "using default cmake script dashboard.cmake" ) 
:: set DASHBOARD_SCRIPT_FILE=%6
::default value is develop(dashboard.cmake)

IF "%DASHBOARD_USE_OTBNAS%" == "1" (
net use R: /delete /Y
net use R: \\otbnas.si.c-s.fr\otbdata\otb /persistent:no
set OTB_DATA_LARGEINPUT_ROOT=R:\OTB-LargeInput
set DOWNLOAD_LOCATION=R:\DataForTests\SuperBuild-archives
) ELSE (
echo "DASHBOARD_USE_OTBNAS env variable is unset or 0"
)
set OTB_DATA_ROOT=C:\dashboard\data\otb-data


::set OMP_NUM_THREADS=1

set CTEST_DASHBOARD_ROOT=C:\dashboard
set CTEST_BUILD_CONFIGURATION=Release

::evironment variable?
:: set CTEST_SITE=noname.no
:: set BUILD_NAME_PREFIX=Win7-vc19



:: actually we shouldn't care for other things in system path.
set TOOLS_DIR=C:\Tools
set SYSPATH=C:\Windows;C:\Windows\system32
set PATH=%SYSPATH%;C:\Windows\System32\wbem
set PATH=%PATH%;%TOOLS_DIR%\clink\0.4.8
IF "%dashboard_otb_branch%" == "cs-si/itk5_preperation" (
set PATH=%PATH%;%TOOLS_DIR%\cmake-3.10.3\bin
) ELSE (
set PATH=%PATH%;%TOOLS_DIR%\cmake-3.5.2\bin
)
set PATH=%PATH%;%TOOLS_DIR%\patch-2.5.9-7\bin
set PATH=%PATH%;%TOOLS_DIR%\wget-1.11.4-1\bin
set PATH=%PATH%;%TOOLS_DIR%\Git-2.9.0\bin
set PATH=%PATH%;%TOOLS_DIR%\ninja
set PATH=%PATH%;%TOOLS_DIR%\jom\bin
set PATH=%PATH%;%TOOLS_DIR%\7zip-16.02
set PATH=%PATH%;%TOOLS_DIR%\swigwin-3.0.12
set PATH=%PATH%;%TOOLS_DIR%\Perl-5.24.1\bin
set PATH=%PATH%;C:\Python27_%COMPILER_ARCH%;C:\Python27_%COMPILER_ARCH%\Scripts
set PATH=%PATH%;C:\Python35_%COMPILER_ARCH%

:: The trick for an easy detection of Python 3 is to clone python.exe into python3.exe
:: Python 2 should appear first in the PATH to be found by default

::set PATH=%PATH%;%TOOLS_DIR%\coreutils-5.3.0\bin

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %COMPILER_ARCH%
@echo on

git config --system --unset credential.helper

set DASHBOARD_SCRIPT_FILE=%CTEST_DASHBOARD_ROOT%\devutils\Config\windows\dashboard.cmake

:: we use ctest option -V instead of ctest -VV to see if that speed up our builds
:: -VV is more verbose and write cycles takes more time on Windows.
:: see jira #1309
set VERBOSE=-VV
IF "%FROM_TASKSCHD%" == "1" ( 
set VERBOSE=-V
)
ctest -C %CTEST_BUILD_CONFIGURATION% %VERBOSE% -S %DASHBOARD_SCRIPT_FILE% -DDROP_SHELL=%DROP_SHELL%
::cmd /C start /wait ctest -C %CTEST_BUILD_CONFIGURATION% -VV -S %DASHBOARD_SCRIPT_FILE%

IF "%DASHBOARD_USE_OTBNAS%" == "1" (
net use R: /delete /Y
)

::cd %CTEST_DASHBOARD_ROOT%\otb\build_%COMPILER_ARCH%\OTB\build
::ctest -R Projection

:Fin
@echo off
echo "Usage : dashboard.bat <compiler_arch>  <cmd_prompt>  [<dasboard_action>] [<otb_git_branch>] [<otb_data_branch>] [<remote_module>]"
echo "All arguments accept only single values. Below '|' means 'or'"
echo "Values for compiler_arch: x86|x64"
echo "Values for cmd_prompt: 0|CMD (CMD option will spawn a cmd.exe into CMAKE_BINARY_DIR along with 'git checkout <otb_git_branch>'"
echo "Values for dasboard_action: BUILD|SUPER_BUILD|PKG"
echo "Values for otb_git_branch: develop|release-5.8| etc.. (default is nightly)"
echo "Values for otb_data_branch: master|release-5.8| etc.. (default is nightly)"
echo "Values for remote_module: SertitObject|Mosaic| etc.. (any official remote module. no defaults)"
echo "Examples:"

echo "dashboard.bat x64 0 BUILD develop master"
echo "dashboard.bat x64 0 SUPER_BUILD release-5.8 (otb-data branch is nightly)"
echo "dashboard.bat x64 0 PKG (generate pacakge of otb)"
echo "dashboard.bat x64 0 BUILD new_feature new_feature_data"
echo "dashboard.bat x64 0 BUILD develop remote_module_data OfficialRemoteModule"
echo "dashboard.bat x64 CMD BUILD develop (drop to cmd.exe with XDK_INSTALL_DIR and CMAKE_PREFIX_PATH set for OTB build)"
echo "dashboard.bat x64 CMD SUPER_BUILD develop (drop to cmd.exe with XDK_INSTALL_DIR and CMAKE_PREFIX_PATH set for a superbuild)"
echo "called :Fin. End of script."

ENDLOCAL
