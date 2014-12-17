#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import re


def showHelp():
  print "Usage : manifestParser.py  MANIFEST_FILE.csv  OTB_SRC_DIRECTORY  [DOT_FILE [MODULE]]"


def searchOTBAndITKIncludes(path):
  includes = []
  
  ifstream = open(path)
  lines = ifstream.readlines()
  ifstream.close()
  
  search_string=r'^#include *([<"])((otb|itk)[^<"_]*\.h)([>"])'
  includeRegexp=re.compile(search_string)
  
  for line in lines:
    gg = includeRegexp.match(line)
    if (gg != None) and (len(gg.groups()) == 4):
      includes.append(gg.group(2))
        
  return includes

def searchExternalIncludes(path):
  includes = []
  systemInc = ["string.h","stdio.h","stdint.h","ctype.h","dirent.h","assert.h","sys/types.h","stdlib.h"]
  ifstream = open(path)
  
  search_string=r'^#include *([<"])([^<"]*\.h.*)([>"])'
  includeRegexp=re.compile(search_string)

  for line in ifstream:
    gg = includeRegexp.match(line)
    if (gg != None) and (len(gg.groups()) == 3):
      detection = gg.group(2)
      # remove includes to OTB or ITK
      if len(detection) > 5:
        if detection[0:3] in ["itk","vcl","vnl"]:
          continue
        if detection[0:3] == "otb" and detection[3] != "_":
          continue
      # remove "system" includes (lib C/C++)
      if detection in systemInc:
        continue
      includes.append(detection)
  
  ifstream.close()
  return includes

def parseManifest(path):
  sourceList = {}
  moduleList = {}
  groups = {}
  nbFields = 6
  fd = open(path,'rb')
  # skip first line and detect separator
  firstLine = fd.readline()
  sep = ','
  if (len(firstLine.split(sep)) != nbFields):
    sep = ';'
  if (len(firstLine.split(sep)) != nbFields):
    sep = '\t'
  if (len(firstLine.split(sep)) != nbFields):
    print "Unknown separator"
    return [groups,moduleList,sourceList]
  
  fd.seek(0)
  
  # parse file
  for line in fd:
    if (line.strip()).startswith("#"):
      continue
    words = line.split(sep)
    if (len(words) < (nbFields-1)):
      print "Wrong number of fields, skipping this line"
      continue
    groupName = words[2].strip(" ,;\t\n\r")
    moduleName = words[3].strip(" ,;\t\n\r")
    sourceFile = words[0].strip(" ,;\t\n\r")
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


def parseDependList(path):
  depList = {}
  sep = ','
  fd = open(path,'rb')
  for line in fd:
    words = line.split(sep)
    if len(words) == 2:
      mod = words[0].strip(" ,;\t\n\r")
      dep = words[1].strip(" ,;\t\n\r")
      if not depList.has_key(mod):
        depList[mod] = {}
      depList[mod][dep] = 1
  
  fd.close()
  return depList

def printDepList(depList, cyclicDependentModules=[]):
  for mod in depList.keys():
    print "-------------------------------------------------------------------"
    print "Module "+mod+" depends on :"
    for dep in depList[mod].keys():
      suffix = ""
      if dep in cyclicDependentModules:
        suffix = "   (cyclic)"
      print "  -> "+dep+suffix
      for link in depList[mod][dep]:
        print "    * from "+link["from"]+" to "+link["to"]


def printExternalDepList(externalDep):
  for mod in externalDep:
    print "-------------------------------------------------------------------"
    print "Module "+mod+" depends on external libs :"
    for ext in externalDep[mod]:
      if (ext == "Other"):
        if len(externalDep[mod][ext]) > 0:
          print " -> "+ext
          for inc in externalDep[mod][ext]:
            print "    * from "+inc
      else:
        print " -> "+ext


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

def outputDotCompleteGraph(deplist,outPath):
  nodemap = {}
  nodeproperties = {}
  edges = set()
  for mod in deplist.keys():
    for dep in deplist[mod].keys():
      for link in deplist[mod][dep]:
        if not link["from"] in nodemap.keys():
          nodemap[link["from"]]="node"+str(len(nodemap))
          nodeproperties[nodemap[link["from"]]]={"name":link["from"], "module":mod}
        if not link["to"] in nodemap.keys():
          nodemap[link["to"]]="node"+str(len(nodemap))
          nodeproperties[nodemap[link["to"]]]={"name":link["to"], "module":dep}
        edges.add((nodemap[link["from"]],nodemap[link["to"]]))
  fd = open(outPath,'wb')
  fd.write("digraph modules {\n")
  for inc in nodemap.keys():
    node = nodemap[inc]
    fd.write(node+" [label=\""+nodeproperties[node]["name"]+"\", mod=\""+nodeproperties[node]["module"]+"\"];\n")
  for (i,o) in edges:
    fd.write(i+" -> "+o+" [src=\""+nodeproperties[i]["name"]+"\", dst=\""+nodeproperties[o]["name"]+"\"];\n")
  fd.write("}\n")
  fd.close()


def outputDotPartialGraph(deplist,outPath,module):
  nodemap = {}
  nodeproperties = {}
  edges = set()
  for dep in deplist[module].keys():
    for link in deplist[module][dep]:
      if not link["from"] in nodemap.keys():
        nodemap[link["from"]]="node"+str(len(nodemap))
        nodeproperties[nodemap[link["from"]]]={"name":link["from"], "module":module}
      if not link["to"] in nodemap.keys():
        nodemap[link["to"]]="node"+str(len(nodemap))
        nodeproperties[nodemap[link["to"]]]={"name":link["to"], "module":dep}
      edges.add((nodemap[link["from"]],nodemap[link["to"]]))
  fd = open(outPath,'wb')
  fd.write("digraph modules {\n")
  for inc in nodemap.keys():
    node = nodemap[inc]
    fd.write(node+" [label=\""+nodeproperties[node]["name"]+"\", mod=\""+nodeproperties[node]["module"]+"\"];\n")
  for (i,o) in edges:
    fd.write(i+" -> "+o+" [src=\""+nodeproperties[i]["name"]+"\", dst=\""+nodeproperties[o]["name"]+"\"];\n")
  fd.write("}\n")
  fd.close()


def findExternalDep(include):
  depName = "Other"
  if (include.find("gdal") == 0) or (include.find("ogr") == 0) or (include.find("cpl_") == 0):
    depName = "GDAL"
  elif (include.find("ossim") == 0):
    depName = "Ossim"
  elif (include.find("opencv") == 0):
    depName = "OpenCV"
  elif (include.find("muParser") == 0):
    depName = "MuParser"
  elif (include.find("boost") == 0):
    if (include == "boost/type_traits/is_contiguous.h"):
      depName = "BoostAdapters"
    else:
      depName = "Boost"
  elif (include.find("tinyxml") == 0):
    depName = "TinyXML"
  elif (include.find("mapnik") == 0):
    depName = "Mapnik"
  elif (include.find("kml") == 0):
    depName = "libkml"
  elif (include.find("curl") == 0):
    depName = "Curl"
  elif (include.find("msImageProcessor") == 0):
    depName = "Edison"
  elif (include.find("openjpeg") == 0):
    depName = "OpenJPEG"
  elif (include.find("siftfast") == 0):
    depName = "SiftFast"
  elif (include.find("svm") == 0):
    depName = "LibSVM"
  elif (include.find("expat") >= 0):
    depName = "Expat"
  elif ((include.lower()).find("6s") >= 0):
    depName = "6S"
  elif (include.find("openthread") == 0):
    depName = "OpenThread"
  elif (include == "ConfigFile.h"):
    depName = "ConfigFile"
  else:
    depName = "Other"
  
  return depName

def buildSimpleDep(otbDir,moduleList,sourceList):
  depList = {}
  for mod in moduleList.keys():
    dependance = {}
    for src in moduleList[mod]:
      srcFullPath = op.join(otbDir,src)
      #srcIncludes = codeParser.ParseIncludes(srcFullPath)
      srcIncludes = searchOTBAndITKIncludes(srcFullPath)
      for inc in srcIncludes:
        if inc in sourceList.keys():
          targetModule = sourceList[inc]
          if targetModule != mod:
            # found dependancy outside current module
            if not dependance.has_key(targetModule):
              dependance[targetModule] = []
            dependance[targetModule].append({"from":op.basename(src) , "to":inc})
        else:
          if not inc.startswith("itk"):
            print "Include not found :"+inc
      # also check includes to third parties
      extInc = searchExternalIncludes(srcFullPath)
      for inc in extInc:
        extDepName = findExternalDep(inc)
        if extDepName == "Other":
          print "Unknown dependency : "+inc
        else:
          if not dependance.has_key(extDepName):
            dependance[extDepName] = []
          dependance[extDepName].append({"from":op.basename(src) , "to":inc})
      
    depList[mod] = dependance
  return depList

def buildFullDep(depList):
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
        if not subMod in fullDepList:
          # if not dependency for this subMod, skip
          continue
        for subModDep in depList[subMod]:
          if not subModDep in fullDepList[mod]:
            if not subModDep in newModules:
              newModules.append(subModDep)
      for newMod in newModules:
        fullDepList[mod][newMod] = 1
      depCountAfter = len(fullDepList[mod])
      if (depCountBefore == depCountAfter):
        newDepFound = False
  return fullDepList
  

def buildGraph(depList):
  pass

def getGroup(module,groups):
  myGroup = ""
  for grp in groups:
    if module in groups[grp]:
      myGroup = grp
      break
  return myGroup

def findGroupDeps(groups,depList):
  groupDeps = {}
  for grp in groups:
    for mod in groups[grp]:
      for dep in depList[mod]:
        depGrp = getGroup(dep,groups)
        if not groupDeps.has_key(depGrp):
          groupDeps[depGrp] = 0
        groupDeps[depGrp] += 1
  return groupDeps

def main(argv):
  csvPath = argv[1]
  otbDir = argv[2]
  if len(argv) >= 4:
    csvEdges = argv[3]
  else:
    csvEdges = None
  
  if len(argv) >= 5:
    module = argv[4]
  else:
    module = None
  
  [groups,moduleList,sourceList] = parseManifest(csvPath)
  
  # compute simple dependencies
  depList = buildSimpleDep(otbDir,moduleList,sourceList)
  
  # compute full dependencies
  fullDepList = buildFullDep(depList)
  
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
  cleanDepList = {}
  for mod in depList.keys():
    cleanDepList[mod] = {}
    depListToRemove = []
    for dep1 in depList[mod]:
      for dep2 in depList[mod]:
        if dep2 == dep1:
          continue
        if not dep1 in fullDepList:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep1 in cyclicDependentModules) and \
           (not dep2 in cyclicDependentModules) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in depList[mod]:
      if not dep in depListToRemove:
        cleanDepList[mod][dep] = 1
  
  if len(cyclicDependentModules) > 0:
    print "Check for cyclic dependency :"
    print "Cyclic modules = "+str(len(cyclicDependentModules))+" / "+str(len(depList))
    for grp in groups.keys():
      print "----------------------------------------------"
      print grp
      for mod in groups[grp].keys():
        if mod in cyclicDependentModules:
          print "  -> FAILED "+mod
        else:
          print "  -> PASSED "+mod
  else:
    print "Check for cyclic dependency : OK"

  printDepList(depList,cyclicDependentModules)
  #printGroupTree(groups)
  
  """
  if csvEdges:
    outputCSVEdgeList(depList,csvEdges)
  return 0
  """
  
  if csvEdges and not module:
    outputDotCompleteGraph(depList,csvEdges)
  elif csvEdges and module:
    outputDotPartialGraph(depList,csvEdges,module)
  return 0
  

if __name__ == "__main__":
  if len(sys.argv) < 3 :
    showHelp()
  else:
    main(sys.argv)
