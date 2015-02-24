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
    if op.isfile(op.join(otbDir,item)):
      srcFiles.append(item.strip('./'))
    else:
      print "Input source file not found, will be skipped : "+item
  
  # First, analyse current OTB tree, retrieve :
  #  - module list
  #  - group vs module association
  #  - module dependency graph from otb-module.cmake
  modulesRoot = op.join(otbDir,"Modules")
  
  [depList, optDepList, testDepList] = sourceAPI.parseOTBModuleCmake(modulesRoot)
  fullDepList = manifestParser.buildFullDep(depList)
  oldCleanDepList = sourceAPI.cleanDepList(depList,fullDepList)
  
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
  
  # DEBUG
  #manifestParser.printDepList(newDepList)
  
  # compute full dependencies
  newFullDepList = manifestParser.buildFullDep(newDepList)
  
  # detect cyclic dependencies
  cyclicDependentModules = []
  for mod in newFullDepList.keys():
    if mod in newFullDepList[mod]:
      if not mod in cyclicDependentModules:
        cyclicDependentModules.append(mod)
  if len(cyclicDependentModules) > 0:
    print "Check for cyclic dependency :"
    for mod in cyclicDependentModules:
      print "  -> "+mod+" depends on : "
      print "      "+str(newFullDepList[mod])
    return 1
  else:
    print "Check for cyclic dependency : OK"
  
  newCleanDepList = newDepList #cleanDepList(newDepList,newFullDepList)
  
  # Analyse tests
  testCxx = {}
  for test in newTestList:
    testPath = op.join(otbDir,test)
    res = createTestManifest.parseTestCxx(testPath)
    if res["isTestDriver"]:
      # no need to dispatch test drivers, they can be generated again
      continue
    [newTestDepList,newThirdPartyDep] = createTestManifest.getTestDependencies(res["includes"],newSourceList)
    curGroup = manifestParser.getGroup(newTestList[test],newGroups)
    if not res["hasMain"]:
      # manually add dependency to TestKernel for cxx using a test driver
      # the include to otbTestMain.h header is not located in the cxx
      newTestDepList["TestKernel"] = {"from":test ,"to":"Modules/IO/TestKernel/include/otbTestMain.h"}
    testCxx[test] = {"depList":newTestDepList , \
                     "thirdPartyDep":newThirdPartyDep, \
                     "group":curGroup, \
                     "module":newTestList[test], \
                     "res":res}
  
  allTestDepends = createTestManifest.gatherTestDepends(testCxx,newFullDepList)
  
  # clean the test depends (i.e. ImageIO is dragged by TestKernel)
  cleanTestDepends = {}
  for mod in allTestDepends:
    cleanTestDepends[mod] = {}
    for dep1 in allTestDepends[mod]:
      isClean = True
      for dep2 in allTestDepends[mod]:
        if dep1 == dep2:
          continue
        if dep1 in newFullDepList[dep2]:
          isClean = False
          break
      if isClean:
        cleanTestDepends[mod][dep1] = 1
  
  # give hints on modifications to perform on DEPENDS and TEST_DEPENDS
  for mod in newDepList:
    curGroup = manifestParser.getGroup(mod,newGroups)
    if mod in depList:
      #if 'ITK' in newDepList[mod]: del newDepList[mod]['ITK']
      if bool(sorted(newDepList[mod].keys()) != sorted(depList[mod].keys())):
        newSet = set(newDepList[mod].keys())
        oldSet = set(depList[mod].keys())
        
        print "Module "+mod+"  -> DEPENDS differ : Added: "+str(list(newSet-oldSet))+", Removed: "+str(list(oldSet-newSet))
        
        for dep in (newSet-oldSet):
          print "Dependencies added to "+dep+":"
          for link in newDepList[mod][dep]:
            print link['from']+" -> "+link['to']

        
        #print "Module "+mod+"  -> DEPENDS differ : "+str(depList[mod].keys())+" then "+str(newDepList[mod].keys())
      if mod in cleanTestDepends and mod in testDepList:
        if bool(sorted(cleanTestDepends[mod].keys()) != sorted(testDepList[mod].keys())):
          print "Module "+mod+"  -> TEST_DEPENDS differ : "+str(testDepList[mod].keys())+" then "+str(cleanTestDepends[mod].keys())
    else:
      print "Module "+mod+" new !"
      if mod in newCleanDepList:
        print "  -> DEPENDS : "+str(newCleanDepList[mod].keys())
      if mod in cleanTestDepends:
        print "  -> TEST_DEPENDS : "+str(cleanTestDepends[mod].keys())
    
    #  - fix the otb-module.cmake ?
    #  - fix the target_link_libraries ?
  
  # fix srcList and test declaration
  os.chdir(otbDir)
  for srcFile in srcFiles:
    cleanFile = srcFile.strip('./')
    words = cleanFile.split('/')
    srcMod = words[2]
    srcGrp = words[1]
    srcSub = words[3]
    targetFile = cleanFile.replace(srcGrp+"/"+srcMod,destinationPrefix,1)
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
      if testCxx[targetFile]["res"]["hasMain"]:
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
        testCode = dispatchTests.findTestFromExe(oldCmakelistPath,"otb"+srcMod+"TestDriver","",testCxx[targetFile]["res"]["testFunctions"],'otb_')

        print "Found "+str(len(testCode))+" tests to move"

        sourceAPI.moveTestCode(oldCmakelistPath,cmakelistPath,testCode)
    
  
  # perform hg rename -A
  for srcFile in srcFiles:
    cleanFile = srcFile.strip('./')
    words = cleanFile.split('/')
    srcMod = words[2]
    srcGrp = words[1]
    targetFile = cleanFile.replace(srcGrp+'/'+srcMod,destinationPrefix,1)
    call(["hg","rename","-A",cleanFile,targetFile])
    
  # TODO : hg commit by the user
  
  


if __name__ == "__main__":
  if len(sys.argv) < 4 :
    showHelp()
  else:
    main(sys.argv)

