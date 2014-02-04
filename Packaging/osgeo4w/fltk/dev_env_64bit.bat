@echo off

call "C:\OSGeo4W64\bin\o4w_env.bat"
set pf=%ProgramFiles(x86)%
if "%pf%"=="" set pf=%ProgramFiles%
call "%pf%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64
path %pf%\Microsoft Visual Studio 10.0\Common7\IDE;%PATH%
path %PATH%;C:\Program Files (x86)\CMake 2.8\bin
path %PATH%;C:\Program Files (x86)\Mercurial
path %PATH%;C:\Program Files (x86)\GnuWin32\bin
path %PATH%;C:\Program Files\SlikSvn\bin
path %PATH%;C:\Tcl\bin
