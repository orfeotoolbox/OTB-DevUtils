#!/usr/bin/python
#coding=utf8

import sys
import string
import os
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import shutil
from subprocess import call, PIPE
import dispatchTests


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    OKRED = '\033[91m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

import sourceAPI

def showHelp():
  print "This script will check and update module dependencies so that each module exactly include what it uses."
  print "Usage : moveSource.py  OTB_SRC_DIRECTORY [--dry-run --verbose]"
  print "  OTB_SRC_DIRECTORY : checkout of OTB (will be modified)"


#----------------- MAIN ---------------------------------------------------
def main(argv):
  
  dry_run = False
  verbose = False
   
  otbDir = op.abspath(argv[1])
  
  for i in range(2,4):
    if len(argv)>i:
      if argv[i] == "--dry-run":
        print "Running in dry-run mode"
        dry_run = True
      elif argv[i] == "--verbose":
        verbose = True
        print "Running in verbose mode"
      else:
        print "Unknown option: "+argv[i]
        showHelp()
        return

  modulesRoot = op.join(otbDir,"Modules")
  
  # Modules in this list will only be updated with additional
  # dependencies, nod dependencies will be removed
  blacklist_for_removal = ["CommandLine", "TestKernel", "ApplicationEngine", "OSSIMAdapters"]

  # Parse otb-module.cmake to get declared dependencies
  [depList, optDepList, testDepList] = sourceAPI.parseOTBModuleCmake(modulesRoot)
  
  # Parse source code to get all elements
  [groups,moduleList,sourceList,testList] = sourceAPI.parseModuleRoot(modulesRoot)
  actualDepList = sourceAPI.buildModularDep(otbDir,moduleList,sourceList)
  actualTestDepList = sourceAPI.buildModularDep(otbDir,testList,sourceList)

  changes_required = 0
  no_changes_required = 0

  for module in moduleList:
    # Find group
    group = ""
    
    for grp in groups.keys():
      if module in groups[grp]:
        group = grp

    if len(group) == 0:
      print bcolors.FAIL+ "Error: module "+module+" not found in any group"+bcolor.ENDC
      continue
      

    fancy_module = bcolors.UNDERLINE + group+"/"+module+ bcolors.ENDC

    # Do not process third parties
    if module in groups['ThirdParty']:
      if verbose:
        print fancy_module +" - Ignoring third party module"
    else:
      current_deps = set(depList[module].keys())
      current_actualdeps = set(actualDepList[module].keys())

      to_add = current_actualdeps - current_deps
      to_remove = current_deps - current_actualdeps

      # Handling optional dependencies
      for opt in optDepList[module].keys():
        if opt in to_add:
          if verbose:
            print fancy_module +" - Ignoring optional dependency: "+opt
          to_add.remove(opt)

      current_opt_deps = set(optDepList[module].keys())
      opt_to_remove = current_opt_deps - current_actualdeps

      # Handling test dependencies
      current_test_deps = set(testDepList[module].keys())
      current_actual_test_deps = set(actualTestDepList[module].keys())

      # Do not self link
      if module in current_actual_test_deps:
        current_actual_test_deps.remove(module)

      for dep in current_actualdeps:
        if dep in current_actual_test_deps:
          current_actual_test_deps.remove(dep)
      
      test_deps_to_add = current_actual_test_deps - current_test_deps
      test_deps_to_remove = current_test_deps - current_actual_test_deps

      if group == "Applications":
        if verbose:
          print fancy_module+" - Module in Applications group, TestKernel and CommandLine modules will not be removed from tests dependencies"
        if "TestKernel" in test_deps_to_remove : test_deps_to_remove.remove("TestKernel")
        if "CommandLine" in test_deps_to_remove : test_deps_to_remove.remove("CommandLine")
    
      if module in blacklist_for_removal:
        if verbose:
          print fancy_module+" - Module is black-listed, only additions will be made to dependencies"
        to_remove.clear()
        opt_to_remove.clear()
        test_deps_to_remove.clear()

      if len(to_add) == 0 and len(to_remove) == 0 and len(opt_to_remove) == 0 and len(test_deps_to_add) == 0 and len(test_deps_to_remove) == 0:
        if verbose:
          print fancy_module+ bcolors.OKGREEN + " - No changes required"+ bcolors.ENDC
        no_changes_required+=1
      else:
        changes_required+=1
        if len(to_add) > 0:
          print fancy_module+bcolors.OKBLUE +" - Additional dependencies required: "+str(list(to_add))+ bcolors.ENDC
          if verbose:
            for dep_to_add in to_add:
              for dep_include in actualDepList[module][dep_to_add]:
                print fancy_module+" - needs "+dep_to_add+" because "+dep_include["from"]+" includes "+dep_include["to"]
        if len(to_remove) > 0:
          print fancy_module+bcolors.OKRED + " - Dependencies to remove: "+str(list(to_remove))+ bcolors.ENDC
       
        if len(opt_to_remove) > 0:
          print fancy_module+bcolors.OKRED + " - Optional dependencies to remove: "+str(list(opt_to_remove))+ bcolors.ENDC

        if len(test_deps_to_add):
           print fancy_module+bcolors.OKBLUE+" - Additional test dependencies required: "+str(list(test_deps_to_add))+ bcolors.ENDC
           if verbose:
             for dep_to_add in test_deps_to_add:
               for dep_include in actualTestDepList[module][dep_to_add]:
                 print fancy_module+" - needs "+dep_to_add+" because "+dep_include["from"]+" includes "+dep_include["to"]
        if len(test_deps_to_remove):
           print fancy_module+bcolors.OKRED + " - Test dependencies to remove: "+str(list(test_deps_to_remove))+ bcolors.ENDC

        final_dep = (current_deps | to_add) - to_remove
        final_opt_dep = current_opt_deps - opt_to_remove
        final_test_dep = (current_test_deps | test_deps_to_add) - test_deps_to_remove
        
        if not dry_run:
          cmake_mod_file_path=op.join(otbDir,"Modules",group,module,"otb-module.cmake")      
          print fancy_module+" - Patching file "+cmake_mod_file_path
          sourceAPI.updateModuleDependencies(cmake_mod_file_path,sorted(final_dep),sorted(final_opt_dep), sorted(final_test_dep))
          
          if len(to_add)>0:
              sub_src_CMakeList = op.join(modulesRoot,op.join(otbDir,"Modules",group,module,"src/CMakeLists.txt"))
              if op.isfile(sub_src_CMakeList):
                  print fancy_module+" - Patching file "+sub_src_CMakeList
                  sourceAPI.setTargetLinkLibs(sub_src_CMakeList,"OTB"+module,sorted(to_add))
      if not dry_run and module not in ['SWIG'] and module not in groups["ThirdParty"] and sourceAPI.UpdateLibraryExport(group,module,otbDir):
              print fancy_module+" - Patching main CMakeLists.txt to fix library export"

        

          
  if not dry_run:
    print "\n"+str(changes_required)+" modules were updated, "+str(no_changes_required)+" were not changed."
    print "\n"+bcolors.OKGREEN+"To commit thoses changes, run: "+ bcolors.ENDC +"hg commit -m \"COMP: Automatic update of modules dependencies\"\n"
  else:
    print "\n"+str(changes_required)+" modules should be updated, "+str(no_changes_required)+" are consistent."
  

if __name__ == "__main__":
  if len(sys.argv) < 1 :
    showHelp()
  else:
    main(sys.argv)

