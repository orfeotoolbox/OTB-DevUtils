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
        x.SetRunDir("/data/otbval")
        x.SetOutilsDir("/data/otbval")
        x.SetOtbDataLargeInputDir("/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/data/otbval")
        x.EnableUpdateCurrentSources()

        # -> Active generation makefiles
        x.DisableGenerateMakefiles()
        x.DisableRunTesting() # Run ctest -I 1,1

        # =========    DAY VALIDATION    ============ 
        x.Run("CentOS-linux-64bits-shared-release-itk-external-fltk-external")
