#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import re


def showHelp():
  print "Compute a first guess of module dispatch for OTB examples (TBD values may remain)"
  print "Usage : createExampleManifest.py  MANIFEST_FILE.csv  MODULE_DEPENDS.csv  OTB_SRC_DIRECTORY  OUTPUT_EXAMPLE_MANIFEST"



def main(argv):
  manifestPath = op.expanduser(argv[1])
  moduleDepPath = op.expanduser(argv[2])
  otbDir = op.expanduser(argv[3])
  outManifest = argv[4]
  
  example_dir = op.join(otbDir,"Examples")
  
  # Standard Manifest parsing, extract simple and full dependencies
  [groups,moduleList,sourceList] = manifestParser.parseManifest(manifestPath)
  depList = manifestParser.parseDependList(moduleDepPath)
  fullDepList = manifestParser.buildFullDep(depList)
  # make sure every module is in depList and fullDepList (even if it has no dependencies)
  for mod in moduleList:
    if not depList.has_key(mod):
      depList[mod] = {}
    if not fullDepList.has_key(mod):
      fullDepList[mod] = {}
  
  depListPerGroup = manifestParser.findGroupDeps(groups,depList)
  
  OldFolderPartition = createTestManifest.buildOldFolderPartition(moduleList)
  
  exampleCxx = {}
  
  outFD = open(outManifest,'wb')
  outFD.write("# Monolithic path, Current dir, group name, module name, subDir name, comment\n")
  
  # parse all cxx test files : analyse them and extract their dependencies
  for (d,f) in codeParser.FindBinaries(example_dir):
    fullPath = op.join(d,f)
    shortPath = fullPath.replace(otbDir,'.')
    
    moduleDestination = "TBD"
    groupDestination = "TBD"
    
    res = createTestManifest.parseTestCxx(fullPath)
    
    if res["isTestDriver"]:
      # no need to dispatch test drivers, they can be generated again
      continue
    
    [exampleDepList,thirdPartyDep] = createTestManifest.getTestDependencies(res["includes"],sourceList)
    
    # if no dependency found, at least put Common
    if len(exampleDepList) == 0:
      exampleDepList["Common"] = {"to":"unkown_source"}
    
    # try to clean the dependency list (remove inherited modules)
    ignoreModules = ["ImageIO","VectorDataIO","TestKernel"]
    cleanExampleDepList = []
    depListToRemove = []
    for dep1 in exampleDepList:
      # register the "from" field
      exampleDepList[dep1]["from"] = shortPath
      
      for dep2 in exampleDepList:
        if dep2 == dep1:
          continue
        # avoid IO modules to 'eat' usefull dependencies
        if dep1 in ignoreModules:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in exampleDepList:
      if not dep in depListToRemove:
        cleanExampleDepList.append(dep)
    
    # build all dependencies of the test
    exampleFullDepList = []
    for dep in exampleDepList:
      for subDep in fullDepList[dep]:
        if not subDep in exampleFullDepList:
          exampleFullDepList.append(subDep)
    
    # start guessing
    luckyGuess = None
    guessStep = 1
    
    # try to get the list of module used to partition the corresponding source directory
    guessModules = []
    guessSourceDir = op.split(shortPath.replace("./Examples","./Code"))[0]
    if OldFolderPartition.has_key(guessSourceDir):
      guessModules = OldFolderPartition[guessSourceDir].keys()
    
    # special case for Examples/Application  -> ApplicationEngine
    if guessSourceDir == "./Application":
      guessModules.append("ApplicationEngine")
    
    # first filter : find modules that appear in cleanExampleDepList and in guessModules
    overlappingModules = []
    for dep in cleanExampleDepList:
      if dep in guessModules:
        overlappingModules.append(dep)
    if len(overlappingModules) == 1:
      luckyGuess = overlappingModules[0]
    
    # second filter : find the source file with the closest name
    if not luckyGuess:
      guessStep += 1
      [matchFile, matchPercent] = createTestManifest.findClosestSourceName(f,sourceList)
      if (sourceList[matchFile] in exampleDepList) and (matchPercent > 50.0):
        luckyGuess = sourceList[matchFile]
      elif (sourceList[matchFile] in exampleFullDepList) and (matchPercent > 70.0):
        luckyGuess = sourceList[matchFile]
    
    # third guess :
    # Constrain the search : if the folder containing the test corresponds
    # to a group name, limit the search to the modules in this group
    # Also, separate IO examples from non-IO examples
    if not luckyGuess:
      folderName = op.basename(d)
      if folderName == "Classification":
        folderName = "Learning"
      if folderName in groups:
        groupDestination = folderName
      exampleSmallerDepList = {}
      for dep in exampleDepList:
        if groupDestination != "TBD":
          if dep in groups[groupDestination]:
            exampleSmallerDepList[dep] = 1
        else:
          if not dep in groups["IO"]:
            exampleSmallerDepList[dep] = 1
      if len(exampleSmallerDepList) == 1:
        luckyGuess = exampleSmallerDepList.keys()[0]
      elif len(exampleSmallerDepList) > 1:
        # filter again to get top-level dependencies
        doubleCleanDepList = []
        depListToRemove = []
        for dep1 in exampleSmallerDepList:
          for dep2 in exampleSmallerDepList:
            if dep2 == dep1:
              continue
            if (dep2 in fullDepList[dep1]) and \
               (not dep2 in depListToRemove):
              depListToRemove.append(dep2)
        for dep in exampleSmallerDepList:
          if not dep in depListToRemove:
            doubleCleanDepList.append(dep)
        if len(doubleCleanDepList) == 1:
          luckyGuess = doubleCleanDepList[0]
      elif len(exampleSmallerDepList) == 0:
        # No dependence in guessed group
        # choose the most probable module in that group
        for mod in moduleList:
          if mod.startswith(folderName) and (mod in groups[groupDestination]):
            luckyGuess = mod
            break
      
    
    # fourth filter : if there is only one dependency in cleanExampleDepList : take it
    if not luckyGuess:
      guessStep += 1
      if len(cleanExampleDepList) == 1:
        luckyGuess = cleanExampleDepList[0]
    
    
    # DEBUG
    if not luckyGuess:
      print shortPath+" : "+str(exampleDepList.keys())
      print shortPath+" : "+str(exampleSmallerDepList.keys()) 
      luckyGuess = "TBD"
    
    if luckyGuess:
      moduleDestination = luckyGuess
    else:
      pass
      #print f + " -> " + str(exampleDepList)
      #print f + " -> "+ matchFile + " ( " + str(matchPercent) + "% )"
    
    # if module is found and not group, deduce group
    if groupDestination == "TBD" and moduleDestination != "TBD":
      groupDestination = manifestParser.getGroup(moduleDestination,groups)
    
    
    exampleCxx[shortPath] = {"depList":exampleDepList , "thirdPartyDep":thirdPartyDep, "group":groupDestination, "module":moduleDestination}
    outFD.write(shortPath+","+op.basename(op.dirname(shortPath))+","+groupDestination+","+moduleDestination+",example,\n")
  
  outFD.close()
  
  # sum all test dependencies in every module
  #allTestDepends = createTestManifest.gatherTestDepends(exampleCxx,fullDepList)
  
  
  # DEBUG
  #manifestParser.printGroupTree(groups)
  
  #manifestParser.printDepList(allTestDepends)


if __name__ == "__main__":
  if len(sys.argv) < 5 :
    showHelp()
  else:
    main(sys.argv)
