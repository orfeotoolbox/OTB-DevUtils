#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import networkx as nx
import re


def showHelp():
  print "Usage : manifestParser.py  MANIFEST_FILE.csv  OTB_SRC_DIRECTORY  [DOT_FILE]"


def searchExternalIncludes(path):
  includes = []
  systemInc = ["string.h","stdio.h","stdint.h","ctype.h","dirent.h","assert.h","sys/types.h"]
  ifstream = open(path)
  
  search_string=r'^#include *([<"])([^<"]*\.h.*)([>"])'
  includeRegexp=re.compile(search_string)

  for line in ifstream:
    gg = includeRegexp.match(line)
    if (gg != None) and (len(gg.groups()) == 3):
      detection = gg.group(2)
      # remove includes to OTB or ITK
      if len(detection) > 5:
        if detection[0:3] in ["otb","itk","vcl","vnl"]:
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
  
  # parse file
  for line in fd:
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


def printDepList(depList, cyclicDependentModules=None):
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
    fd.write(i+" -> "+o+";\n")
  fd.write("}\n")
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
  cleanDepList = {}
  for mod in depList.keys():
    cleanDepList[mod] = {}
    depListToRemove = []
    for dep1 in depList[mod]:
      for dep2 in depList[mod]:
        if dep2 == dep1:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep1 in cyclicDependentModules) and \
           (not dep2 in cyclicDependentModules) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in depList[mod]:
      if not dep in depListToRemove:
        cleanDepList[mod][dep] = 1
  
  externalDep = {}
  for mod in moduleList.keys():
    externalDep[mod] = {"Other":{}}
    for src in moduleList[mod]:
      fullPath = op.join(otbDir,src)
      extInc = searchExternalIncludes(fullPath)
      for inc in extInc:
        if (inc.find("gdal") == 0) or (inc.find("ogr") == 0) or (inc.find("cpl_") == 0):
          externalDep[mod]["GDAL"] = 1
        elif (inc.find("ossim") == 0):
          externalDep[mod]["OSSIM"] = 1
        elif (inc.find("opencv") == 0):
          externalDep[mod]["OpenCV"] = 1
        elif (inc.find("muParser") == 0):
          externalDep[mod]["MuParser"] = 1
        elif (inc.find("boost") == 0):
          externalDep[mod]["Boost"] = 1
        elif (inc.find("tinyxml") == 0):
          externalDep[mod]["TinyXML"] = 1
        elif (inc.find("mapnik") == 0):
          externalDep[mod]["Mapnik"] = 1
        elif (inc.find("kml") == 0):
          externalDep[mod]["LibKML"] = 1
        elif (inc.find("curl") == 0):
          externalDep[mod]["Curl"] = 1
        elif (inc.find("msImageProcessor") == 0):
          externalDep[mod]["Edison"] = 1
        elif (inc.find("openjpeg") == 0):
          externalDep[mod]["OpenJPEG"] = 1
        elif (inc.find("siftfast") == 0):
          externalDep[mod]["SiftFast"] = 1
        elif (inc.find("svm") == 0):
          externalDep[mod]["LibSVM"] = 1
        else:
          externalDep[mod]["Other"][inc] = 1
  
  
  
  """
  print "Clean Modules :"
  for mod in fullDepList.keys():
    if not mod in cyclicDependentModules:
      print " -> "+mod
  """
  
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

  #printDepList(depList,cyclicDependentModules)
  #printGroupTree(groups)
  printExternalDepList(externalDep)
  
  if csvEdges:
    outputDotCompleteGraph(depList,csvEdges)
  
  return 0


if __name__ == "__main__":
  if len(sys.argv) < 3 :
    showHelp()
  else:
    main(sys.argv)
