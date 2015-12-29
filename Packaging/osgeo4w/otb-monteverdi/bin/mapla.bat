@echo off
SET OSGEO4W_ROOT=@osgeo4w@
call "%OSGEO4W_ROOT%"\bin\o4w_env.bat
start "Monteverdi Application Launcher" /B "%OSGEO4W_ROOT%"\apps\orfeotoolbox\monteverdi\bin\mapla.exe %*
@echo on