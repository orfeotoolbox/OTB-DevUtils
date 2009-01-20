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
        x.SetRunDir("/cygdrive/z")
        x.SetOutilsDir("/cygdrive/z")
        x.SetOtbDataLargeInputDir("/cygdrive/z/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/z")
        # The sources are updated by raoul CentOS OS
        x.DisableUpdateSources()

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
	

