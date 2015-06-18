textreplace -std -t bin\monteverdi2.bat

mkdir "%OSGEO4W_STARTMENU%"
xxmklink "%OSGEO4W_STARTMENU%\Monteverdi2.lnk" "%OSGEO4W_ROOT%\bin\monteverdi2.bat" " " \ "Monteverdi2" 1 "%OSGEO4W_ROOT%\apps\orfeotoolbox\monteverdi2\icons\monteverdi2.ico"
xxmklink "%ALLUSERSPROFILE%\Desktop\Monteverdi2.lnk" "%OSGEO4W_ROOT%\bin\monteverdi2.bat" " " \ "Monteverdi2" 1 "%OSGEO4W_ROOT%\apps\orfeotoolbox\monteverdi2\icons\monteverdi2.ico"

