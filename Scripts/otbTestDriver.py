import os, subprocess, urllib2, sys, shutil
from datetime import *

class otbTestDriver:
    # Driver name
    DriverName="Default"
    # True if logging is enabled
    UseLogFile=True
    # Log files directory
    LogFilesPath=''
    # The log file
    LogFile=''
    # Is the log file created ?
    LogFileCreated = False
    # Path to the mercurial exe
    MercurialExecutable='hg'
    # Path to the cmake exe
    CMakeExecutable='cmake'
    # Path to the ctest exe
    CTestExecutable='ctest'
    # Path to the cpack exe
    CPackExecutable='cpack'

    def SetDriverName(self,name):
        self.DriverName = name

    def SetUseLogFile(self,flag):
        self.UseLogFile = flag

    def SetLogFilesPath(self,path):
        self.LogFilesPath = path

    def SetCMakeExecutable(self,name):
	self.CMakeExecutable=name
    
    def SetCTestExecutable(self,name):
	self.CTestExecutable=name
    
    def SetCPackExecutable(self,name):
	self.CPackExecutable=name

    def SetMercurialExecutable(self,name):
	self.MercurialExecutable=name
    
    # Create a log file
    def CreateLogFile(self):
        if not self.LogFileCreated:
            date = datetime.today().isoformat('-').__str__()
            date = date.replace(".","-")
            date = date.replace(":","-")
            date = date.replace(" ","-")
	    date = date[:-7]
            self.LogFile=self.LogFilesPath+"/"+self.DriverName+"-"+date+".log"
            self.LogFileCreated = True
    
    # Log a message
    def Log(self,type,message):
        if self.UseLogFile and len(message) > 0:
            self.CreateLogFile()
            logFile = open(self.LogFile,'a')
            date = datetime.now().isoformat("-").__str__()
	    date = date[:-7]
            logFile.write(date+" "+type+": "+message+"\n")
            logFile.close()

    # Change to some directory
    def ChangeDirectory(self,directory):
        try:
            os.chdir(directory)
            self.Log("INFO","Changing to directory "+directory)
        except:
            self.Log("ERROR","Failed to change to directory "+directory)

    # Clean up a directory
    def CleanDirectory(self,directory):
        self.Log("INFO","Cleaning up directory "+directory)

	if not os.path.exists(directory):
	    self.Log("WARNING","Directory "+directory+" does not exist")
	    return

	shutil.rmtree(directory)
	os.makedirs(directory)
#        for root, dirs, files in os.walk(directory, topdown=False):
#                for name in files:
#                    path = os.path.join(root,name)
#                    try:
#                        os.remove(path)
#                    except:
#                        self.Log("ERROR","Failed to remove file "+path)
#                for name in dirs:
#                    path = os.path.join(root,name)
#                    try:
#                        os.rmdir(os.path.join(root,name))
#                    except:
#                        self.Log("ERROR","Failed to remove directory "+path)

    # Call a given command
    def Command(self,command,comment=""):
        if comment != "":
            self.Log("INFO",comment)
	commandWithLogs=command
        self.Log("INFO","Executing command "+command)
	logFile = open(self.LogFile,'a')

	# Use Popen or call subprocess method following the python version
	if sys.version < '2.6':
	    process  = subprocess.call(command, stdout=logFile, shell=True)
	else:
	    process = subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE,bufsize=1)
	    outputs = process.communicate()
	    coutlines = outputs[0].split("\n")
	    cerrlines = outputs[1].split("\n")
	    retcode = process.returncode
	    for line in coutlines:
		self.Log("COUT",line)
	    for line in cerrlines:
		self.Log("CERR",line)
	    if retcode < 0:
		self.Log("ERROR","Command failed.")

    # Update sources
    def HgPullUpdate(self,directory,revision = ''):
        self.Log("INFO ","Mercurial update")
        self.ChangeDirectory(os.path.normpath(directory))
        self.Command(self.MercurialExecutable+' pull',"Mercurial pull")
	if revision == '':
             self.Command(self.MercurialExecutable+' update default',"Mercurial update")
	else:
	     self.Command(self.MercurialExecutable+' update -r '+revision,"Mercurial update (rev: "+revision+")")

    # Run cmake configuration
    def CMake(self,srcDir,buildDir,configFile='',additionalOptions=''):
	self.ChangeDirectory(buildDir)
        configureCommand=self.CMakeExecutable+' '+additionalOptions+' -C '+configFile+' '+srcDir
        self.Command(configureCommand,"CMake configuration")

    # Run ctest
    def CTest(self,buildDir,args=""):
	self.ChangeDirectory(buildDir)
        self.Command(self.CTestExecutable+' -A CMakeCache.txt -A '+self.LogFile+' '+args)

    def CPack(self,buildDir,args=""):
	self.ChangeDirectory(buildDir)
        self.Command(self.CPackExecutable+' '+args)

    def GetNightlyRevisions(self):
	proxyURL = os.environ.get("http_proxy")
	proxyURL = proxyURL.strip('"')
	print "Proxy found: "+proxyURL
	if proxyURL!='':
            proxy = urllib2.ProxyHandler({'http': proxyURL})
            auth = urllib2.HTTPBasicAuthHandler()
            opener = urllib2.build_opener(proxy, auth, urllib2.HTTPHandler)
            urllib2.install_opener(opener)
	revisions={}
	revisions['OTB']=urllib2.urlopen('http://host2.orfeo-toolbox.org/nightly/libNightlyNumber').read()
        revisions['OTB-Applications']=urllib2.urlopen('http://host2.orfeo-toolbox.org/nightly/applicationsNightlyNumber').read()
        revisions['Monteverdi']=urllib2.urlopen('http://host2.orfeo-toolbox.org/nightly/MonteverdiNightlyNumber').read()
        revisions['Wrapping']=urllib2.urlopen('http://host2.orfeo-toolbox.org/nightly/wrappingNightlyNumber').read()
	self.Log("INFO","Nightly revisions retrieved. OTB:"+revisions['OTB']+", Applications:"+revisions['OTB-Applications']+", Monteverdi:"+revisions['Monteverdi']+", Wrapping:"+revisions['Wrapping'])
	return revisions
