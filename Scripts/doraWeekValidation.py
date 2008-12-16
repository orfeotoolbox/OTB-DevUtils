import sys
import os
import platform
import socket
#import subprocess

if __name__ == "__main__":
        # Update OTB-DevUtils module
#        os.chdir("OTB-DevUtils")
#        subprocess.call("hg pull", shell=True)
#        subprocess.call("hg update -r default", shell=True)
#        print os.getcwd()
#        sys.path.append(os.getcwd()+"/Scripts")
        sys.path.append(os.getcwd()+"/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        #os.chdir("..")
        x=Validation.TestProcessing()

        # Set dirs
        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("/ORFEO/otbval")
        x.DisableUpdateSources()

        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")

        # Set generate makefile options
	# Set Generals configuration tests
#        x.EnableMakeClean()
	x.EnableGenerateMakefiles()
#        x.DisableBuildExamples()
#        x.DisableUseVtk()
#        x.DisableTestOTBApplicationsWithInstallOTB()
#        x.DisableGlUseAccel()
     
#        x.DisableCTest()
        
        # List of platform must been tested
	try:
		x.Run("linux-static-debug-itk-internal-fltk-internal")
	except:
		print 'Error while executing run method', sys.exc_info()[0]
		exit(1)



