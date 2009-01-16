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

        x.SetOutilsDir("Z:\\")
        x.SetRunDir("Z:\\")
        x.SetOtbDataLargeInputDir("Z:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("Z:\\")
        # The sources are hupdated by raoul CentOS OS
        x.DisableUpdateSources()
        
        # -> Active generation makefiles
        if sys.argv[1] == "WEEKEND":
                x.DisableBuildExamples()
                x.DisableTestOTBApplicationsWithInstallOTB()
                x.DisableGlUseAccel()
                x.DisableUseVtk()
                x.EnableGenerateMakefiles()
        else:
                x.DisableGenerateMakefiles()

        # List of platform must been tested
	x.Run("visualExpress2008-static-debug-itk-internal-fltk-internal")
#        if sys.argv[1] == "WEEKEND":
#	        x.Run("visualExpress2008-static-release-itk-internal-fltk-internal")
#	        x.Run("visualExpress2008-static-debug-itk-external-fltk-external")
#	        x.Run("visualExpress2008-static-release-itk-external-fltk-external")

