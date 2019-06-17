
# Setup directories
mkdir C:\build
mkdir C:\GitLab-Runner
mkdir C:\tools
mkdir C:\tools\bin
mkdir C:\clcache

echo "Setup otbbot user"
$passbot = Read-Host 'What is otbbot password?' -asSecureString
New-LocalUser "otbbot" -Password $passbot -PasswordNeverExpires -FullName "OTB bot" -Description "bot for OTB CI"

# Function to grand the Log On as a service rights to an account
function Add-ServiceLogonRight([string] $Username) {
    Write-Host "Enable ServiceLogonRight for $Username"

    $tmp = New-TemporaryFile
    secedit /export /cfg "$tmp.inf" | Out-Null
    (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$Username" | sc -Encoding ascii "$tmp.inf"
    secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
    secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
    rm $tmp* -ea 0
}

Add-ServiceLogonRight otbbot

# Function to add a path to global path
Function global:ADD-PATH()
{
[Cmdletbinding()]
param
(
[parameter(Mandatory=$True,
ValueFromPipeline=$True,
Position=0)]
[String[]]$AddedFolder
)

# Get the current search path from the environment keys in the registry.
$OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path

# See if a new folder has been supplied.
IF (!$AddedFolder)
{ Return 'No Folder Supplied. $ENV:PATH Unchanged'}

# See if the new folder exists on the file system.
IF (!(TEST-PATH $AddedFolder))
{ Return 'Folder Does not Exist, Cannot be added to $ENV:PATH' }

# See if the new Folder is already in the path.
IF ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
{ Return 'Folder already within $ENV:PATH' }

# Set the New Path
$NewPath=$OldPath+';'+$AddedFolder

Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

# Show our results back to the world
Return $NewPath
}

cd C:\tools

# Force the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

echo "Download installers"
Invoke-WebRequest -UseBasicParsing https://download.visualstudio.microsoft.com/download/pr/132e0a34-74d0-4898-8e97-4b0be453109f/129df5ac4bc87c09e78198069aec4d93/vs_buildtools.exe -OutFile vs_buildtools.exe
Invoke-WebRequest -UseBasicParsing https://download.microsoft.com/download/B/0/C/B0C80BA3-8AD6-4958-810B-6882485230B5/standalonesdk/sdksetup.exe -OutFile sdksetup.exe
Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v2.21.0.windows.1/Git-2.21.0-64-bit.exe -OutFile Git_Setup.exe
Invoke-WebRequest -UseBasicParsing https://www.7-zip.org/a/7z1900-x64.exe -OutFile 7Zip_Setup.exe
Invoke-WebRequest -UseBasicParsing https://www.orfeo-toolbox.org/packages/archives/Misc/patch-2.5.9-7-setup.exe -OutFile patch_Setup.exe
Invoke-WebRequest -UseBasicParsing https://www.orfeo-toolbox.org/packages/archives/Misc/wget-1.11.4-1-setup.exe -OutFile wget_Setup.exe
Invoke-WebRequest -UseBasicParsing https://www.orfeo-toolbox.org/packages/archives/Misc/swigwin-3.0.12.zip -OutFile swigwin.zip
Invoke-WebRequest -UseBasicParsing http://download.qt.io/official_releases/jom/jom.zip -OutFile jom.zip
Invoke-WebRequest -UseBasicParsing https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-win.zip -OutFile ninja-win.zip
Invoke-WebRequest -UseBasicParsing https://www.python.org/ftp/python/3.5.4/python-3.5.4.exe -OutFile python35.exe
Invoke-WebRequest -UseBasicParsing https://www.python.org/ftp/python/3.5.4/python-3.5.4-amd64.exe -OutFile python35-amd64.exe
Invoke-WebRequest -UseBasicParsing http://dependencywalker.com/depends22_x86.zip -OutFile depends22_x86.zip
Invoke-WebRequest -UseBasicParsing https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe -OutFile gitlab-runner.exe
Invoke-WebRequest -UseBasicParsing https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-win64-x64.zip -OutFile cmake.zip
Invoke-WebRequest -UseBasicParsing http://strawberryperl.com/download/5.28.1.1/strawberry-perl-5.28.1.1-64bit-portable.zip -OutFile perl.zip


echo "Install Git to C:\tools\Git"
.\Git_Setup.exe | Out-Null
del Git_Setup.exe

echo "Install 7Zip to C:\tools\7-Zip"
.\7Zip_Setup.exe | Out-Null
del 7Zip_Setup.exe

echo "Setup patch and wget to C:\tools\GnuWin32"
.\patch_Setup.exe | Out-Null
.\wget_Setup.exe | Out-Null
del patch_Setup.exe
del wget_Setup.exe

echo "Install Perl to C:\tools\perl"
mkdir perl
C:\tools\7-Zip\7z.exe x -y -operl perl.zip
del perl.zip

echo "Install swig to C:\tools\swig"
C:\tools\7-Zip\7z.exe x -y swigwin.zip
ren swigwin-3.0.12 swig
del swigwin.zip

echo "Install cmake to C:\tools\cmake"
C:\tools\7-Zip\7z.exe x -y cmake.zip
ren cmake-3.14.2-win64-x64 cmake
del cmake.zip

echo "Install jom to C:\tools\bin"
C:\tools\7-Zip\7z.exe x -y -obin jom.zip
del jom.zip

echo "Install ninja to C:\tools\bin"
C:\tools\7-Zip\7z.exe x -y -obin ninja-win.zip
del ninja-win.zip

echo "Install dependency walker in C:\tools\bin"
C:\tools\7-Zip\7z.exe x -y -obin depends22_x86.zip
del depends22_x86.zip

echo "Install Python 3.5.4 32bit to C:\tools\Python35-x86"
.\python35.exe | Out-Null
del python35.exe

echo "Install Python 3.5.4 64bit to C:\tools\Python35-x64"
.\python35-amd64.exe | Out-Null
del python35-amd64.exe

echo "Install clcache and numpy for both 32bit and 64bit"
C:\tools\Python35-x86\Scripts\pip3.exe install clcache
C:\tools\Python35-x64\Scripts\pip3.exe install clcache

C:\tools\Python35-x86\Scripts\pip3.exe install numpy
C:\tools\Python35-x64\Scripts\pip3.exe install numpy

C:\tools\Python35-x86\Scripts\pip3.exe install scons
C:\tools\Python35-x64\Scripts\pip3.exe install scons

C:\tools\Python35-x86\Scripts\pip3.exe install Mako
C:\tools\Python35-x64\Scripts\pip3.exe install Mako

echo "Install Gitlab-runner with shell executor"
move gitlab-runner.exe C:\GitLab-Runner
cd C:\GitLab-Runner
$runnerName = Read-Host 'What is gitlab runner name?'
$runnerToken = Read-Host 'What is gitlab runner registration token?'
.\gitlab-runner.exe register --non-interactive --url "https://gitlab.orfeo-toolbox.org/" --registration-token $runnerToken --executor "shell" --description $runnerName --tag-list "windows" --locked="false"
$passbotPlainText = $passbot | ConvertFrom-SecureString
.\gitlab-runner.exe install --user ".\otbbot" --password "$passbotPlainText"
.\gitlab-runner.exe start

echo "Create updater script for gitlab runner and register a daily task"
Set-Content -Path updater.ps1 -Value "cd C:\Gitlab-Runner"
Add-Content -Path updater.ps1 -Value ".\gitlab-runner stop"
Add-Content -Path updater.ps1 -Value "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
Add-Content -Path updater.ps1 -Value "Invoke-WebRequest -UseBasicParsing https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe -OutFile gitlab-runner.exe"
Add-Content -Path updater.ps1 -Value ".\gitlab-runner start"

schtasks /create /tn GitlabRunnerUpdater /tr C:\Gitlab-Runner\updater.ps1 /sc monthly /d 22 /st 01:00

cd C:\tools

echo "Add some paths to global configuration"
ADD-PATH C:\tools\bin
ADD-PATH C:\tools\cmake\bin
ADD-PATH C:\tools\GnuWin32\bin
ADD-PATH C:\tools\7-Zip
ADD-PATH C:\tools\swig
ADD-PATH C:\tools\Python35-x64

echo "Setup ssh key for otbbot"
$botcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList otbbot, $passbot
Start-Process powershell.exe -Wait -Credential $botcred -NoNewWindow -ArgumentList "mkdir C:\Users\otbbot\.ssh"

Set-Content -Path config -Value "Host gitlab.orfeo-toolbox.org"
Add-Content -Path config -Value "HostName gitlab.orfeo-toolbox.org"
Add-Content -Path config -Value "IdentityFile C:\Users\otbbot\.ssh\id_otbbot"
Start-Process powershell.exe -Wait -Credential $botcred -NoNewWindow -ArgumentList "copy config C:\Users\otbbot\.ssh"
del config

# TODO: add gitlab.orfeo-toolbox.org to known hosts

Set-Content -Path id_otbbot -Value ""
echo "Copy paste the ssh key for otbbot into this text file and save it"
notepad.exe id_otbbot
$dummy = Read-Host 'Press Enter to continue'
Start-Process powershell.exe -Wait -Credential $botcred -ArgumentList "copy id_otbbot C:\Users\otbbot\.ssh"
del id_otbbot

echo "Setup git parameters"
Set-Content -Path .gitconfig -Value "[user]"
Add-Content -Path .gitconfig -Value "  name = otbbot"
Add-Content -Path .gitconfig -Value "  email = otbbot@orfeo-toolbox.org"
Start-Process powershell.exe -Wait -Credential $botcred -ArgumentList "copy .gitconfig C:\Users\otbbot"
Start-Process powershell.exe -Wait -Credential $botcred -ArgumentList "git lfs install" -WorkingDirectory C:\Users\otbbot
del .gitconfig

echo "Install Win8.1 SDK"
.\sdksetup.exe | Out-Null
del sdksetup.exe

echo "Install Visual Studio with Win10 SDK, msvc 15, msvc 17 and msvc 19"
.\vs_buildtools.exe | Out-Null

echo "You can reboot"

echo "Setup for Runner TOML:"
echo "[[runners]]"
echo "  builds_dir = C:\\build"
echo "  [runners.custom_build_dir]"
echo "    enabled = true"
