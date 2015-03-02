#!/usr/bin/python
#coding=utf8

import sys
import string
import os
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import documentationCheck
import shutil
from subprocess import call, PIPE
import dispatchTests
import sourceAPI

def showHelp():
  print "This script will check and update test drivers to match exactly tests function in cxx tests files"
  print "Usage : moveSource.py  OTB_SRC_DIRECTORY"
  print "  OTB_SRC_DIRECTORY : checkout of OTB (will be modified)"


#----------------- MAIN ---------------------------------------------------

def update(otbDir):
  modulesRoot = op.join(otbDir,"Modules")

  [groups,moduleList,sourceList,testList] = sourceAPI.parseModuleRoot(modulesRoot)

  patch_count = 0
          
  for (g,modules) in groups.iteritems():
    for m in modules:
      functions = []
      for f in testList[m]:
        if f.endswith(".cxx") and not f.endswith("TestDriver.cxx"):
          new_functions = sourceAPI.ParseTestCode(f)
          if len(new_functions) == 0:
            print "No functions found in "+f
          else:
            functions+=new_functions
          
      # Some filtering to avoid corner cases
      # filter main functions
      functions = [func.strip(' \n\t\r') for func in functions if func != "main"]
      # filter *_generic and generic_* functions because they are likely to be called by real tests functions
      functions = [func for func in functions if not func.startswith("generic_") and not func.startswith("generic_") and not func.endswith("_generic")]
            
      if m == "ImageBase":
        # In this module, there is buch of functions ending by TestRegion which are not real tests functions
        functions = [func for func in functions if not func.endswith("TestRegion")]
      if m == "ImageIO":
        # In this module, there is buch of functions ending by TestRegion which are not real tests functions
        functions = [func for func in functions if not func.endswith("GenericTest")]
        functions = [func for func in functions if not func.endswith("Generic")]
      if m == "IOGDAL":
        functions = [func for func in functions if not func.startswith("otbGeneric")]
        functions = [func for func in functions if not func.endswith("Generic")]
        
      cmake = op.join(otbDir,"Modules",g,m,"test","CMakeLists.txt")
      if op.isfile(cmake):
        if sourceAPI.CheckTestDriverInTestCMakeLists(cmake,m):
          patch_count+=1
          # if op.isfile(cmake):
          #     functions = sourceAPI.ParseCMakeListsTestCode(cmake)
          
          #print g+"/"+m+": test functions found: "+str(functions)
      test_driver = op.join(otbDir,"Modules",g,m,"test","otb"+m+"TestDriver.cxx")
      if len(functions) > 0:
        if not op.isfile(test_driver):
          sourceAPI.initializeTestDriver(test_driver)
        if sourceAPI.updateTestDriver2(test_driver,functions):
          patch_count+=1
      else:
        if os.path.isfile(test_driver):
          print g+"/"+m+": no tests were found but a test driver exists"
                    
  return patch_count

def main(argv):
  
    otbDir = op.abspath(argv[1])

    patch_count = update(otbDir)
    
    print "\n"+str(patch_count)+" files were patched\n"

    print "To commit those changes, run hg commit -m \"TEST: Automatic update of test drivers\"\n"

if __name__ == "__main__":
  if len(sys.argv) < 1 :
    showHelp()
  else:
    main(sys.argv)

