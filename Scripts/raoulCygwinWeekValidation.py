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

        x=Validation.TestProcessing()
        x.SetRunDir("/cygdrive/e")
        x.SetOutilsDir("/cygdrive/e")
        x.SetOtbDataLargeInputDir("/cygdrive/e/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/e")
        x.DisableUpdateSources()
#        x.EnableUpdateSources()

        x.EnableGenerateMakefiles()

        # List of platform must been tested
	x.Run("cygwin-static-debug-itk-internal-fltk-internal")
	

