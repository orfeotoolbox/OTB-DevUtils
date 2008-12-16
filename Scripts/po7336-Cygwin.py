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
        x.SetRunDir("/cygdrive/d")
        x.SetOutilsDir("/cygdrive/d")
        x.SetOtbDataLargeInputDir("/cygdrive/d/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/d")
        x.EnableUpdateSources()

        # -> Active generation makefiles
        if sys.argv[1] == "WEEKEND":
                x.DisableTestOTBApplicationsWithInstallOTB()
                x.DisableUseVtk()
                x.DisableGlUseAccel()
                x.DisableBuildExamples()

                x.EnableGenerateMakefiles()
        else:
                x.DisableGenerateMakefiles()

        # List of platform must been tested
	x.Run("cygwin-static-debug-itk-internal-fltk-internal")
        if sys.argv[1] == "WEEKEND":
	        x.Run("cygwin-shared-release-itk-internal-fltk-internal")

