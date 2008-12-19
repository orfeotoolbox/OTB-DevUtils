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
        x.SetRunDir("D:\\OTB")
        x.SetOutilsDir("D:\\OTB")
        x.SetOtbDataLargeInputDir("D:\\OTB\\WWW.ORFEO-TOOLBOX.ORG-CS-NIGHTLY\\OTB-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("D:\\OTB")
        x.EnableUpdateSources()

        x.DisableGenerateMakefiles()
        #x.DisableUseVtk()
        x.Run("visualExpress2005-static-debug-itk-internal-fltk-internal")
		
        if sys.argv[1] == "WEEKEND":
                x.DisableBuildExamples()
                x.DisableTestOTBApplicationsWithInstallOTB()
                x.DisableGlUseAccel()
				x.DisableUseVtk()
                x.EnableGenerateMakefiles()
                x.Run("visualExpress2005-static-release-itk-internal-fltk-internal")
