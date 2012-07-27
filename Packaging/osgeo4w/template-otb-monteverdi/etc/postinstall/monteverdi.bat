textreplace -std -t bin\monteverdi.bat

mkdir "%OSGEO4W_STARTMENU%"
xxmklink "%OSGEO4W_STARTMENU%\Monteverdi (1.12.0).lnk"       "%OSGEO4W_ROOT%\bin\monteverdi.bat" " " \ "Monteverdi (1.12.0)" 1 "%OSGEO4W_ROOT%\apps\orfeotoolbox\monteverdi\icons\monteverdi.ico"
xxmklink "%ALLUSERSPROFILE%\Desktop\Monteverdi (1.12.0).lnk" "%OSGEO4W_ROOT%\bin\monteverdi.bat" " " \ "Monteverdi (1.12.0)" 1 "%OSGEO4W_ROOT%\apps\orfeotoolbox\monteverdi\icons\monteverdi.ico"

