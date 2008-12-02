import sys
import os
import platform
import socket
import string
import subprocess

if __name__ == "__main__":
        # Update OTB-DevUtils module
        os.chdir("OTB-DevUtils")
        subprocess.call("hg pull", shell=True)
        subprocess.call("hg update -r default", shell=True)

        sys.path.append(os.getcwd()+"/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        x=Validation.TestProcessing()
        
        # Example1 : Only Updates sources
        # -------------------------------
        x.SetSourcesDir("/ORFEO/otbval")
	x.RunUpdateSources()
	exit(1)

        # Example2: Run configuration testing
        # -----------------------------------

        # Set the external tools version
#        x.SetVtkVersion("5.2")
#        x.SetItkVersion("3.8.0")
#        x.SetFltkVersion("1.1.9")

        # Set Generals configuration tests
#        x.DisableBuildExamples()
#        x.DisableUseVtk()
#        x.DisableTestOTBApplicationsWithInstallOTB()
        x.SetSourcesDir("W:\\")
#        x.SetSourcesDir("/ORFEO/otbval")
        x.EnableUpdateSources()
        x.SetOutilsDir("E:\\")
        x.SetRunDir("E:\\")
        
#        x.EnableMakeClean()
        x.EnableGenerateMakefiles()
#        x.DisableCTest()

        # List of platform must been tested
        x.Run("visual8-static-release-itk-external-fltk-external")
