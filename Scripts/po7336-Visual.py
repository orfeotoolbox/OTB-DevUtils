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
        x.SetRunDir("D:\\")
        x.SetOutilsDir("D:\\")
        x.SetOtbDataLargeInputDir("D:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("D:\\")
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
# Provisoire pour Dashboard du 17 décembre
        x.DisableBuildExamples()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.DisableUseVtk()
        x.EnableGenerateMakefiles()

        # List of platform must been tested
	x.Run("visual7-static-debug-itk-internal-fltk-internal")
        if sys.argv[1] == "WEEKEND":
        	x.Run("visual7-static-release-itk-external-fltk-external")
