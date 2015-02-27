#!/usr/bin/python
#coding=utf8
import glob
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
import updateModuleDependencies
import updateDoxyGroup
import updateTestDrivers

import sourceAPI

def showHelp():
  print "Script to move a source file from an OTB tree (after modularization)"+\
    ". Allows to move source files from a module to an other and operate the "+\
    "corresponding modifications in the build system."
  print "Usage : moveSource.py  OTB_SRC_DIRECTORY  TARGET_MODULE  SOURCES_FILES"
  print "  OTB_SRC_DIRECTORY : checkout of modular OTB (will be modified)"
  print "  TARGET_MODULE     : destination module"
  print "                      use 'group/module' in case of a new module"
  print "  SOURCES_FILES     : list of source files"



#----------------- MAIN ---------------------------------------------------
def main(argv):
  otbDir = op.abspath(argv[1])
  targetModule = argv[2]
  targetGroup = "TBD"
  if targetModule.count('/') == 1:
    pos = targetModule.find('/')
    targetGroup = targetModule[0:pos]
    targetModule = targetModule[pos+1:]
  if targetModule == "":
    print "Wrong module name, check input argument : "+argv[2]
  if targetGroup == "":
    print "Wrong group name, check input argument : "+argv[2]

  print "Target module: "+targetGroup+"/"+targetModule

  srcFiles = []
  for item in argv[3:]:
    src = item
    if not src.startswith("Modules/"):
      src = "Modules/"+src
    if op.isfile(op.join(otbDir,src)):
      srcFiles.append(src.strip('./'))
    else:
      print "Input source file not found, will be skipped : "+src
  
  # First, analyse current OTB tree, retrieve :
  #  - module list
  #  - group vs module association
  modulesRoot = op.join(otbDir,"Modules")
  
  [depList, optDepList, testDepList] = sourceAPI.parseOTBModuleCmake(modulesRoot)
  #fullDepList = manifestParser.buildFullDep(depList)
  #oldCleanDepList = sourceAPI.cleanDepList(depList,fullDepList)
  
  [groups,moduleList,sourceList,testList] = sourceAPI.parseModuleRoot(modulesRoot)
  
  # DEBUG
  #manifestParser.printDepList(depList)
  #print str(moduleList)
  
  
  # Second, operate the move
  if targetModule in moduleList:
    targetGroup = manifestParser.getGroup(targetModule,groups)
  else:
    if targetGroup == 'TBD':
      print "Error : group name must be specified for new modules (use group/module syntax)"
      return 1
  
  destinationPrefix = op.join(targetGroup,targetModule)
  for srcFile in srcFiles:
    cleanFile = srcFile.strip('./')
    words = cleanFile.split('/')
    srcMod = words[2]
    srcGrp = words[1]
    targetFile = cleanFile.replace(srcGrp+'/'+srcMod,destinationPrefix,1)
    targetPath = op.join(otbDir,op.dirname(targetFile))
    if not op.isdir(targetPath):
      os.makedirs(targetPath)
    shutil.move(op.join(otbDir,cleanFile),targetPath)
  
  # Compute new modules dependencies
  [newGroups,newModuleList,newSourceList,newTestList] = sourceAPI.parseModuleRoot(modulesRoot)
  newDepList = sourceAPI.buildModularDep(otbDir,newModuleList,newSourceList)
  newTestDepList = sourceAPI.buildModularDep(otbDir,newTestList,newSourceList)
  
  # compute full dependencies
  newFullDepList = manifestParser.buildFullDep(newDepList)
  
  # detect cyclic dependencies
  cyclicDependentModules = []
  for mod in newFullDepList.keys():
    if mod in newFullDepList[mod]:
      if not mod in cyclicDependentModules:
        cyclicDependentModules.append(mod)
  if len(cyclicDependentModules) > 0:
    print "Check for cyclic dependency : Failed"
    for m in cyclicDependentModules:
      cycle = sourceAPI.getCyclicDep(m,newDepList)
      print "Cycle for module "+m+": "+str(cycle)
      if len(cycle) > 0:
        a = m
        for c in cycle:
          b = c
          print a+" -> "+b+": "
          for dep in newDepList[a][b]:
            print "\t"+dep["from"]+" -> "+dep["to"]
          a = c
    
    #manifestParser.printDepList(newDepList,cyclicDependentModules)
    return 1
  else:
    print "Check for cyclic dependency : Passed"
  
  # fix srcList and test declaration
  os.chdir(otbDir)
  for srcFile in srcFiles:
    cleanFile = srcFile.strip('./')
    words = cleanFile.split('/')
    srcMod = words[2]
    srcGrp = words[1]
    srcSub = words[3]
    targetFile = cleanFile.replace(srcGrp+"/"+srcMod,destinationPrefix,1)
    # call hg rename -A
    call(["hg","rename","-A",cleanFile,targetFile])
    #  - for input files in 'src' : adapt OTBModule_SRC
    if srcSub == "src" and len(words) == 5:
      # remove entry in previous module
      removed = [op.basename(srcFile)]
      added = []
      cmakelistPath = op.join(modulesRoot,op.join(srcGrp,op.join(srcMod,"src/CMakeLists.txt")))
      # Check that there are some source file remaining in src dir
      source_files = filter(os.path.isfile, glob.glob(op.join(modulesRoot,srcGrp,srcMod,'src')+'/*.c*'))
      if len(source_files) >0 :
        sourceAPI.updateSourceList(cmakelistPath,"OTB"+srcMod+"_SRC",added,removed)
      else:
        # There are no more sources here, the whole src module can be removed
        print "Removing src dir in "+srcGrp+"/"+srcMod+", since it does not contain source files anymore"
        call(["hg","remove",op.join(modulesRoot,srcGrp,srcMod,'src')+"/*"])
      # add entry in target module
      removed = []
      added = [op.basename(srcFile)]
      cmakelistPath = op.join(modulesRoot,op.join(destinationPrefix,"src/CMakeLists.txt"))
      if not op.exists(cmakelistPath):
        sourceAPI.initializeSrcCMakeLists(cmakelistPath,targetModule)
        call(["hg","add",cmakelistPath.replace(otbDir,".")])
      sourceAPI.updateSourceList(cmakelistPath,"OTB"+targetModule+"_SRC",added,removed)
    if srcSub == "test" and len(words) == 5:
      # analyse test
      res = createTestManifest.parseTestCxx(op.join(otbDir,targetFile))
      
      if res["hasMain"]:
        print "Test with main ("+targetFile+") : not handled for now"
      else:
        # remove entry in previous module source list
        removed = [op.basename(srcFile)]
        added = []
        oldCmakelistPath = op.join(modulesRoot,op.join(srcGrp,op.join(srcMod,"test/CMakeLists.txt")))
        oldTestDriverPath = op.join(modulesRoot,op.join(srcGrp,op.join(srcMod,"test/otb"+srcMod+"TestDriver.cxx")))
        sourceAPI.updateSourceList(oldCmakelistPath,"OTB"+srcMod+"Tests",added,removed)
        
        # add entry in target module source list
        removed = []
        added = [op.basename(srcFile)]
        cmakelistPath = op.join(modulesRoot,op.join(destinationPrefix,"test/CMakeLists.txt"))
        testDriverPath = op.join(modulesRoot,op.join(destinationPrefix,"test/otb"+targetModule+"TestDriver.cxx"))
        if not op.exists(cmakelistPath):
          # there was no test before : initialize CMakeLists.txt
          sourceAPI.initializeTestCMakeLists(cmakelistPath,targetModule)
          call(["hg","add",cmakelistPath.replace(otbDir,".")])
        if not op.exists(testDriverPath):
          # there was no test before : initialize test driver
          sourceAPI.initializeTestDriver(testDriverPath)
          call(["hg","add",testDriverPath.replace(otbDir,".")])
        sourceAPI.updateSourceList(cmakelistPath,"OTB"+targetModule+"Tests",added,removed)
        
        #  - move test declaration
        testCode = dispatchTests.findTestFromExe(oldCmakelistPath,"otb"+srcMod+"TestDriver","",res["testFunctions"],'otb_')
        
        # get set_test_properties()
        testProp = dispatchTests.findTestProperties(oldCmakelistPath,testCode.keys())
        
        print "Found "+str(len(testCode))+" tests to move"

        sourceAPI.moveTestCode(oldCmakelistPath,cmakelistPath,testCode,testProp)

  for mod in newModuleList:
    curGroup = manifestParser.getGroup(mod,newGroups)
    
    # fix the otb-module.cmake
    cmake_module_path = op.join(modulesRoot,op.join(curGroup,op.join(mod,"otb-module.cmake")))
    cmakel_module_path = op.join(modulesRoot,op.join(curGroup,op.join(mod,"CMakeLists.txt")))
    if (not op.exists(cmake_module_path)) and (mod == targetModule):
      # initialize new otb-module.cmake if new module
      sourceAPI.initializeOTBModuleCmake(cmake_module_path,mod)
      with_lib = False
      if op.exists(op.join(curGroup,op.join(mod,"src"))):
        with_lib = True
      sourceAPI.initializeOTBModuleCMakeLists(cmakel_module_path,mod,with_lib)
      call(["hg","add",cmakel_module_path.replace(otbDir,".")])
      
      call(["hg","add",cmake_module_path.replace(otbDir,".")])
    
    #  - fix the target_link_libraries
    src_dir = op.join(modulesRoot,curGroup,mod,"src")

    sub_src_CMakeList = op.join(modulesRoot,op.join(curGroup,op.join(mod,"src/CMakeLists.txt")))

  # Update the module dependencies
  print "Updating module dependencies ..."
  count = updateModuleDependencies.update(otbDir)
  print str(count)+" modules were updated"
  
  # Update the module test driver
  print "Updating test drivers ..."
  count = updateTestDrivers.update(otbDir)
  print str(count)+" files updated"

  # Update the group declaration in doxygen
  print "Updating doxygen group declaration ..."
  updateDoxyGroup.update(otbDir)

  # TODO : hg commit by the user
  print "\nTo commit those changes, run: hg commit -m \"ENH: Automatic move of files to module "+targetGroup+"/"+targetModule+"\"\n"
  print "It is advised to run updateModuleDependencies.py script beforehand.\n"
  


if __name__ == "__main__":
  if len(sys.argv) < 4 :
    showHelp()
  else:
    main(sys.argv)

