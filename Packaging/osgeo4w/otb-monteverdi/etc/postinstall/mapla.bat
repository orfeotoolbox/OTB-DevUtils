textreplace -std -t bin\mapla.bat

mkdir "%OSGEO4W_STARTMENU%"
xxmklink "%OSGEO4W_STARTMENU%\Mapla.lnk" "%OSGEO4W_ROOT%\bin\mapla.bat" " " \ "Mapla" 1 "%OSGEO4W_ROOT%\apps\orfeotoolbox\monteverdi\icons\monteverdi.ico"
xxmklink "%ALLUSERSPROFILE%\Desktop\Mapla.lnk" "%OSGEO4W_ROOT%\bin\mapla.bat" " " \ "Mapla" 1 "%OSGEO4W_ROOT%\apps\orfeotoolbox\monteverdi\icons\monteverdi.ico"