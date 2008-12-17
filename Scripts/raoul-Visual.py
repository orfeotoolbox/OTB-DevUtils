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

        x.SetOutilsDir("E:\\")
        x.SetRunDir("E:\\")
        x.SetOtbDataLargeInputDir("E:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("E:\\")
        x.EnableUpdateSources()

        
        # -> Active generation makefiles
#        if sys.argv[1] == "WEEKEND":
#                x.DisableBuildExamples()
#                x.DisableTestOTBApplicationsWithInstallOTB()
#                x.DisableGlUseAccel()
#                x.DisableUseVtk()
#                x.EnableGenerateMakefiles()
#        else:
#                x.DisableGenerateMakefiles()
# Provisoire pour Dashboard du 17 decembre
        x.DisableBuildExamples()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.DisableUseVtk()
        x.EnableGenerateMakefiles()

        # List of platform must been tested
	x.Run("visual8-static-debug-itk-internal-fltk-internal")
        if sys.argv[1] == "WEEKEND":
	        x.Run("visual8-static-release-itk-internal-fltk-internal")
	        x.Run("visual8-static-debug-itk-external-fltk-external")
	        x.Run("visual8-static-release-itk-external-fltk-external")

