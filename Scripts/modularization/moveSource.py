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
    manifestParser.printDepList(newDepList,cyclicDependentModules)
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
      sourceAPI.updateSourceList(cmakelistPath,"OTB"+srcMod+"_SRC",added,removed)
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
        sourceAPI.updateTestDriver(oldTestDriverPath,added,removed)
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
        sourceAPI.updateTestDriver(testDriverPath,added,removed)
        
        #  - move test declaration
        testCode = dispatchTests.findTestFromExe(oldCmakelistPath,"otb"+srcMod+"TestDriver","",res["testFunctions"],'otb_')
        
        # get set_test_properties()
        testProp = dispatchTests.findTestProperties(oldCmakelistPath,testCode.keys())
        
        print "Found "+str(len(testCode))+" tests to move"

        sourceAPI.moveTestCode(oldCmakelistPath,cmakelistPath,testCode,testProp)
  
  
  # Modules in this list will only be updated with additional
  # dependencies, nod dependencies will be removed
  blacklist_for_removal = ["CommandLine", "TestKernel", "ApplicationEngine", "OSSIMAdapters"]
  finalDep = {}
  finalTestDep = {}
  for mod in newModuleList:
    curGroup = manifestParser.getGroup(mod,newGroups)
    
    # detect third party and skip
    if mod in newGroups['ThirdParty']:
      continue
    
    # handle new modules
    if not mod in depList:
      depList[mod] = {}
    if not mod in optDepList:
      optDepList[mod] = {}
    if not mod in testDepList:
      testDepList[mod] = {}
    
    depBefore = set(depList[mod].keys())
    depAfter = set([])
    if mod in newDepList:
      for dep in newDepList[mod]:
        if not dep in optDepList[mod]:
          depAfter.add(dep)
    if mod in blacklist_for_removal:
      depAfter.update(depBefore)
    if depBefore != depAfter:
      print "Module "+mod+" : DEPENDS : removed : "+str(list(depBefore-depAfter))+" ; added : "+str(list(depAfter-depBefore))
    
    tDepBefore = set(testDepList[mod].keys())
    tDepAfter = set([])
    if mod in newTestDepList:
      for tdep in newTestDepList[mod]:
        if not tdep in (list(depAfter) + optDepList[mod].keys()):
          tDepAfter.add(tdep)
    if mod in blacklist_for_removal:
      tDepAfter.update(tDepBefore)
    if mod in newGroups['Applications']:
      if "TestKernel" in tDepBefore:
        tDepAfter.add("TestKernel")
      if "CommandLine" in tDepBefore:
        tDepAfter.add("CommandLine")
    if tDepBefore != tDepAfter:
      print "Module "+mod+" : TEST_DEPENDS : removed : "+str(list(tDepBefore-tDepAfter))+" ; added : "+str(list(tDepAfter-tDepBefore))
    
    finalDep[mod] = depAfter
    finalTestDep[mod] = tDepAfter
    
    # fix the otb-module.cmake
    cmake_module_path = op.join(modulesRoot,op.join(curGroup,op.join(mod,"otb-module.cmake")))
    if (not op.exists(cmake_module_path)) and (mod == targetModule):
      # initialize new otb-module.cmake if new module
      sourceAPI.initializeOTBModuleCmake(cmake_module_path,mod)
      call(["hg","add",cmake_module_path.replace(otbDir,".")])
    if (depBefore != depAfter) or (tDepBefore != tDepAfter):
      sourceAPI.updateModuleDependencies(cmake_module_path,sorted(depAfter),sorted(optDepList[mod]),sorted(tDepAfter))
    
    #  - fix the target_link_libraries
    sub_src_CMakeList = op.join(modulesRoot,op.join(curGroup,op.join(mod,"src/CMakeLists.txt")))
    if op.isfile(sub_src_CMakeList) and (depBefore != depAfter):
      sourceAPI.setTargetLinkLibs(sub_src_CMakeList,"OTB"+mod,sorted(depAfter))
  
  # TODO : hg commit by the user
  print "To commit those changes, run: hg commit -m \"ENH: Automatic move of files to module "+targetModule+"\"\n"
  


if __name__ == "__main__":
  if len(sys.argv) < 4 :
    showHelp()
  else:
    main(sys.argv)

