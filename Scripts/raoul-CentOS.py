import sys
import os
import platform
import socket

if __name__ == "__main__":
        sys.path.append(os.getcwd()+"/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)
        if len(sys.argv) != 2:
                print "Error  -->   Usage: ", sys.argv[0], " WEEK/WEEKEND"
                exit(1)

        x=Validation.TestProcessing()
        x.SetRunDir("/data")
        x.SetOutilsDir("/data")
        x.SetOtbDataLargeInputDir("/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/data")
#        x.EnableUpdateSources()
        x.DisableUpdateSources()

        # -> Active generation makefiles
        if sys.argv[1] == "WEEKEND":
                x.DisableTestOTBApplicationsWithInstallOTB()
                x.DisableUseVtk()
                x.DisableGlUseAccel()
                x.DisableBuildExamples()
                x.EnableGenerateMakefiles()
		x.SetDistribName("CentOS-5.2")
        else:
                x.DisableGenerateMakefiles()

        # List of platform must been tested
	x.Run("linux-64bits-static-debug-itk-internal-fltk-internal")
#        if sys.argv[1] == "WEEKEND":
#        	x.Run("linux-shared-release-itk-internal-fltk-internal")
	

