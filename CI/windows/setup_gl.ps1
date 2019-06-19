cd C:\tools

# Force the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

echo "Compile & install mesa3D, need:"
echo " - Python 2.7"
echo " - scons"
echo " - Mako"
echo " - win_flex"
echo " - win_bison"

Invoke-WebRequest -UseBasicParsing https://mesa.freedesktop.org/archive/mesa-19.0.3.tar.gz -OutFile mesa.tar.gz
# Invoke-WebRequest -UseBasicParsing https://mesa.freedesktop.org/archive/windows-utils/bison-2.4.1.zip -OutFile bison.zip
# Invoke-WebRequest -UseBasicParsing https://mesa.freedesktop.org/archive/windows-utils/flex-2.5.35.zip -OutFile flex.zip
Invoke-WebRequest -UseBasicParsing https://www.python.org/ftp/python/2.7.16/python-2.7.16.amd64.msi -OutFile python-2.7.amd64.msi
Invoke-WebRequest -UseBasicParsing https://github.com/mhammond/pywin32/releases/download/b224/pywin32-224.win-amd64-py2.7.exe -OutFile pywin32-amd64-py2.7.exe
Invoke-WebRequest -UseBasicParsing https://kent.dl.sourceforge.net/project/winflexbison/win_flex_bison-latest.zip -OutFile win_flex_bison.zip
Invoke-WebRequest -UseBasicParsing https://mesa.freedesktop.org/archive/glu/glu-9.0.0.tar.gz -OutFile glu.tar.gz

echo "Install python 2.7 into C:\tools\Python27-x64 (skip tcltk, documentation, register extension)"
Start-Process -Wait .\python-2.7.amd64.msi

echo "Install scons and mako"
C:\tools\Python27-x64\Scripts\pip.exe install scons
C:\tools\Python27-x64\Scripts\pip.exe install mako

echo "Install win_flex and win_bison"
mkdir win_flex_bison
C:\tools\7-Zip\7z.exe x -y -owin_flex_bison win_flex_bison.zip

echo "Install pywin"
.\pywin32-amd64-py2.7.exe | Out-Null

# TODO: build LLVM for x86 and x64

echo "Prepare mesa build"
C:\tools\7-Zip\7z.exe x -y mesa.tar.gz
C:\tools\7-Zip\7z.exe x -y mesa.tar

cd mesa-19.0.3
$OLD_PATH=$env:PATH
$env:PATH="$OLD_PATH;C:\tools\Python27-x64;C:\tools\Python27-x64\Scripts;C:\tools\win_flex_bison"
scons platform=windows build=release machine=x86_64 libgl-gdi
scons platform=windows build=release machine=x86 libgl-gdi
mkdir C:\tools\GL
mkdir C:\tools\GL\x64
mkdir C:\tools\GL\x64\bin
mkdir C:\tools\GL\x64\lib
mkdir C:\tools\GL\x64\include
mkdir C:\tools\GL\x86
mkdir C:\tools\GL\x86\bin
mkdir C:\tools\GL\x86\lib
mkdir C:\tools\GL\x86\include
copy build\windows-x86_64\gallium\targets\libgl-gdi\opengl32.* C:\tools\GL\x64\lib
copy build\windows-x86\gallium\targets\libgl-gdi\opengl32.* C:\tools\GL\x86\lib
move C:\tools\GL\x64\lib\opengl32.dll C:\tools\GL\x64\bin
move C:\tools\GL\x86\lib\opengl32.dll C:\tools\GL\x86\bin
xcopy /s .\include C:\tools\GL\x64\include
xcopy /S .\include C:\tools\GL\x86\include
$env:PATH="$OLD_PATH"
cd C:\tools

echo "Build GLU"
C:\tools\7-Zip\7z.exe x -y glu.tar.gz
C:\tools\7-Zip\7z.exe x -y glu.tar
Invoke-WebRequest -UseBasicParsing https://www.orfeo-toolbox.org/packages/archives/Misc/GLU-CMakeLists.txt -OutFile glu-9.0.0/CMakeLists.txt
Invoke-WebRequest -UseBasicParsing https://www.orfeo-toolbox.org/packages/archives/Misc/GLU32.def -OutFile glu-9.0.0/GLU32.def
cd glu-9.0.0
mkdir build-x64
cd build-x64
cmd /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat`" x64 & cmake -GNinja -DCMAKE_INSTALL_PREFIX=C:/tools/GL/x64 -DCMAKE_BUILD_TYPE=Release -DOPENGL_INCLUDE_DIR=C:/tools/GL/x64/include -DOPENGL_gl_LIBRARY=C:/tools/GL/x64/lib/opengl32.lib .. & ninja install"
cd ..
mkdir build-x86
cd build-x86
cmd /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat`" x86 & cmake -GNinja -DCMAKE_INSTALL_PREFIX=C:/tools/GL/x86 -DCMAKE_BUILD_TYPE=Release -DOPENGL_INCLUDE_DIR=C:/tools/GL/x86/include -DOPENGL_gl_LIBRARY=C:/tools/GL/x86/lib/opengl32.lib .. & ninja install"
cd ..
del build-*
cd C:\tools














