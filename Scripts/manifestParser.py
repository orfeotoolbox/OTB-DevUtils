#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import networkx as nx


def showHelp():
  print "Usage : manifestParser.py  MANIFEST_FILE.csv  OTB_SRC_DIRECTORY  [CSV_EDGE_LIST]"


def parseManifest(path):
  sourceList = {}
  moduleList = {}
  groups = {}
  nbFields = 6
  fd = open(path,'rb')
  # skip first line
  fd.readline()
  for line in fd:
    words = line.split(',')
    if (len(words) < nbFields):
      print "Wrong number of fields, skipping this line"
      continue
    groupName = words[2].strip(" ,\t\n\r")
    moduleName = words[3].strip(" ,\t\n\r")
    sourceFile = words[0].strip(" ,\t\n\r")
    sourceName = op.basename(sourceFile)
    if not groups.has_key(groupName):
      groups[groupName] = {}
    groups[groupName][moduleName] = 1
    if not moduleList.has_key(moduleName):
      moduleList[moduleName] = []
    moduleList[moduleName].append(sourceFile)
    sourceList[sourceName] = moduleName
  fd.close()
  # manually add otbConfigure.h (belonging to Common)
  sourceList['otbConfigure.h'] = 'Common'
  
  return [groups,moduleList,sourceList]


def printDepList(depList):
  for mod in depList.keys():
    print "-------------------------------------------------------------------"
    print "Module "+mod+" depends on :"
    for dep in depList[mod].keys():
      print "  -> "+dep
      for link in depList[mod][dep]:
        print "    * from "+link["from"]+" to "+link["to"]


def printGroupTree(groups):
  for grp in groups.keys():
    print grp
    for mod in groups[grp].keys():
      print "  -> "+mod

def outputCSVEdgeList(depList,outPath):
  fd = open(outPath,'wb')
  for mod in depList.keys():
    for dep in depList[mod].keys():
      fd.write(mod+","+dep+"\n")
  fd.close()

def buildGraph(depList):
  pass

def main(argv):
  csvPath = argv[1]
  otbDir = argv[2]
  if len(argv) >= 4:
    csvEdges = argv[3]
  else:
    csvEdges = None
  
  [groups,moduleList,sourceList] = parseManifest(csvPath)
  
  depList = {}
  for mod in moduleList.keys():
    dependance = {}
    for src in moduleList[mod]:
      srcFullPath = op.join(otbDir,src)
      srcIncludes = codeParser.ParseIncludes(srcFullPath)
      for inc in srcIncludes:
        if inc in sourceList.keys():
          targetModule = sourceList[inc]
          if targetModule != mod:
            # found dependancy outside current module
            if not dependance.has_key(targetModule):
              dependance[targetModule] = []
            dependance[targetModule].append({"from":op.basename(src) , "to":inc})
        else:
          print "Include not found :"+inc
    depList[mod] = dependance
  
  # compute full dependencies
  fullDepList = {}
  for mod in depList.keys():
    fullDepList[mod] = {}
    for tmp in depList[mod].keys():
      fullDepList[mod][tmp] = 1
    newDepFound = True
    while (newDepFound):
      depCountBefore = len(fullDepList[mod])
      # try to explore each modules in dependency list
      newModules = []
      for subMod in fullDepList[mod]:
        for subModDep in depList[subMod]:
          if not subModDep in fullDepList[mod]:
            if not subModDep in newModules:
              newModules.append(subModDep)
      for newMod in newModules:
        fullDepList[mod][newMod] = 1
      depCountAfter = len(fullDepList[mod])
      if (depCountBefore == depCountAfter):
        newDepFound = False
  
  # detect cyclic dependencies
  cyclicDependentModules = []
  for mod in fullDepList.keys():
    if mod in fullDepList[mod]:
      if not mod in cyclicDependentModules:
        cyclicDependentModules.append(mod)
  
  # clean full dependencies : 
  # - if module 'a' depends on 'b' 'c' and 'd'
  # - if module 'b' depens on 'd'
  # - if 'b' and 'd' are clean
  #   -> then remove 'd' from 'a' dependency list
  # it will be considered as inherited from 'b'
  """
  cleanDepList = depList.copy()
  for mod in cleanDepList.keys():
    depListToRemove = []
    for dep1 in cleanDepList[mod]:
      for dep2 in cleanDepList[mod]:
        if dep2 == dep1:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep1 in cyclicDependentModules) and \
           (not dep2 in cyclicDependentModules) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for duplicatedDep in depListToRemove:
      del(cleanDepList[mod][duplicatedDep])
  """
  
  """
  print "Clean Modules :"
  for mod in fullDepList.keys():
    if not mod in cyclicDependentModules:
      print " -> "+mod
  """
  
  print "Check for cyclic dependency :"
  for grp in groups.keys():
    print "----------------------------------------------"
    print grp
    for mod in groups[grp].keys():
      if mod in cyclicDependentModules:
        print "  -> FAILED "+mod
      else:
        print "  -> PASSED "+mod
  
  printDepList(depList)
  #printGroupTree(groups)
  
  if csvEdges:
    outputCSVEdgeList(depList,csvEdges)
  
  return 0


if __name__ == "__main__":
  if len(sys.argv) < 3 :
    showHelp()
  else:
    main(sys.argv)
