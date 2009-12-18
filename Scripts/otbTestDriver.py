import os, subprocess
from datetime import *

class otbTestDriver:
    # Driver name
    DriverName="Default"
    # Build Path
    BuildPath=""
    # True if a cmake configuration file is needed
    UseConfigurationFile=True
    # Path to the cmake configuration file
    ConfigurationFilePath=""
    # Path to the source code
    SourcePath=""
    # Build from scratch
    BuildFromScratch=True
    # True if logging is enabled
    UseLogFile=True
    # Log files directory
    LogFilesPath=""
    # The log file
    LogFile=""
    # Is the log file created ?
    LogFileCreated = False

    def SetDriverName(self,name):
        self.DriverName = name

    def SetBuildPath(self,path):
        self.BuildPath=path

    def SetUseConfigurationFile(self,flag):
        self.UseConfigurationFile = flag

    def SetConfigurationFile(self,path):
        self.ConfigurationFile=path

    def SetSourcePath(self,path):
        self.SourcePath = path

    def SetUseLogFile(self,flag):
        self.UseLogFile = flag

    def SetLogFilesPath(self,path):
        self.LogFilesPath = path

    # Create a log file
    def CreateLogFile(self):
        if not self.LogFileCreated:
            date = datetime.today().isoformat('-').__str__()
            date = date.replace(".","-")
            date = date.replace(":","-")
            date = date.replace(" ","-")
            self.LogFile=self.LogFilesPath+"/"+self.DriverName+"-"+date+".log"
            self.LogFileCreated = True
    
    # Log a message
    def Log(self,type,message):
        if self.UseLogFile:
            self.CreateLogFile()
            logFile = open(self.LogFile,'a')
            date = datetime.now().isoformat("-").__str__()
            logFile.write(date+" "+type+": "+message+"\n")
            logFile.close()

    # Change to some directory
    def ChangeDirectory(self,directory):
        try:
            os.chdir(self.SourcePath)
            self.Log("INFO ","Changed to directory "+directory)
        except:
            self.Log("ERROR","Failed to change to directory "+directory)

    # Clean up a directory
    def CleanDirectory(self,directory):
        self.Log("INFO","Cleaning up directory "+directory)
        for root, dirs, files in os.walk(directory, topdown=False):
                for name in files:
                    path = os.path.join(root,name)
                    try:
                        os.remove(path)
                    except:
                        self.Log("ERROR","Failed to remove file "+path)
                for name in dirs:
                    path = os.path.join(root,name)
                    try:
                        os.rmdir(os.path.join(root,name))
                    except:
                        self.Log("ERROR","Failed to remove directory "+path)

    # Call a given command
    def Command(self,command,comment=""):
        if comment != "":
            self.Log("INFO ",comment)
        self.Log("INFO","Executing command "+command)
        logfile = None
        if self.UseLogFile:
            logfile = open(self.LogFile,'a')
        retcode = subprocess.call(command, stdout=logfile, stderr=logfile, bufsize=1, shell=True)
        if self.UseLogFile:
            logfile.close()
        if retcode < 0:
            self.Log("ERROR","Command failed.")

    # Update sources
    def UpdateSources(self):
        self.Log("INFO ","Updating sources")
        self.ChangeDirectory(self.SourcePath)
        self.Command("hg pull","Mercurial pull")
        self.Command("hg update","Mercurial update")

    # Clean up build directory
    def CleanBuild(self):
        self.Log("INFO ","Cleaning any previous build")
        self.CleanDirectory(self.BuildPath)

    # Run cmake configuration
    def Configure(self):
        configureCommand="cmake"
        if self.UseConfigurationFile:
            configureCommand = configureCommand +" -C "+self.ConfigurationFile
        configureCommand = configureCommand +" "+self.SourcePath 
        self.Command(configureCommand,"CMake configuration")

    # Run ctest
    def Test(self,args=""):
        self.Command("ctest "+args)

