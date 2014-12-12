#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import re


def showHelp():
  print "Usage : createTestManifest.py  MANIFEST_FILE.csv  MODULE_DEPENDS.csv  OTB_SRC_DIRECTORY  OUTPUT_TEST_MANIFEST  [TEST_DEPENDS_CSV]"

def extractTestFunctionName(testCode):
  fullString = ""
  for line in testCode:
    cleanLine = line.strip(" \t#\n\r")
    fullString = fullString + cleanLine + " "
  
  startPos = fullString.find("(")
  endPos = fullString.rfind(")")
  
  fullString = fullString[startPos+1:endPos]
  fullString.replace('\t',' ')
  # collapse mutli-spaces
  sizeChanged = True
  while (sizeChanged):
    sizeBefore = len(fullString)
    fullString = fullString.replace('  ',' ')
    sizeAfter = len(fullString)
    if (sizeBefore == sizeAfter):
      sizeChanged = False
  
  words = fullString.split(' ')
  # Start at words[2] (0 is testname, 1 is TestDriver)
  currentPos = 2
  while (words[currentPos].startswith('--')):
    if words[currentPos] in ["--without-threads","--ignore-order"]:
      currentPos = currentPos + 1
    elif words[currentPos] in ["--with-threads","--epsilon-boundary"]:
      currentPos = currentPos + 2
    elif words[currentPos] in ["--compare-binary"]:
      currentPos = currentPos + 3
    elif words[currentPos] in ["--compare-n-images","--compare-n-ascii"]:
      nbComp = int(words[currentPos+1])
      currentPos = currentPos + 3 + 2 * nbComp
    elif words[currentPos] in ["--compare-n-binary"]:
      nbComp = int(words[currentPos+1])
      currentPos = currentPos + 2 + 2 * nbComp
    elif words[currentPos] in ["--ignore-lines-with"]:
      nbComp = int(words[currentPos+1])
      currentPos = currentPos + 2 + nbComp
    else:
      currentPos = currentPos + 4
  
  return words[currentPos]

def parseTestCxx(path):
  res = {"isTestDriver":False, "hasMain":False, "testFunctions":[], "includes":[]}
  
  registeredTests = []
  includes = []
  
  systemInc = ["string.h","stdio.h","stdint.h","ctype.h","dirent.h",\
               "assert.h","sys/types.h","stdlib.h","profile.h","windows.h",\
               "math.h"]
  
  search_string=r'^#include *([<"])([^<"]*\.h.*)([>"])'
  includeRegexp=re.compile(search_string)
  
  main_search = r'^int main\(.*\)'
  func_search = r'^int ([A-Za-z0-9]+)\(int [^,]+,char[^,]+\[\]\)'
  shortFunc_search = r'^([A-Za-z0-9]+)\(int [^,]+,char[^,]+\[\]\)'
  
  mainRe = re.compile(main_search)
  funcRe = re.compile(func_search)
  shortRe = re.compile(shortFunc_search)
  
  refLevel = 0
  currentLevel = 0
  commented = False
  previousLine = ""
  
  fd = open(path,'rb')
  for line in fd:
    # skip useless lines
    cleanLine = line.replace("\n"," ")
    cleanLine = cleanLine.strip(" \t\n\r")
    comment1Pos = cleanLine.find("//")
    if comment1Pos >= 0:
      cleanLine = cleanLine[0:comment1Pos]
    comment2Pos = cleanLine.find("/*")
    comment3Pos = cleanLine.find("*/")
    if (comment2Pos >= 0) and (comment3Pos > comment2Pos):
      cleanLine = cleanLine[0:comment2Pos] + cleanLine[comment3Pos+2:]
    if (comment2Pos < 0) and (comment3Pos >= 0):
      commented = False
      cleanLine = cleanLine[comment3Pos+2:]
    if commented:
      continue
    if (comment2Pos >= 0) and (comment3Pos < 0):
      commented = True
      cleanLine = cleanLine[0:comment2Pos]
    
    # collapse mutli-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
    
    if len(cleanLine) == 0:
      continue
    
    # search for includes
    gg = includeRegexp.match(line)
    if (gg != None) and (len(gg.groups()) == 3):
      detection = gg.group(2)
      if not detection in systemInc:
        res["includes"].append(detection)
      if detection == "otbTestMain.h":
        res["isTestDriver"] = True
    # search for function declaration or test registration
    if res["isTestDriver"]:
      if cleanLine.startswith("REGISTER_TEST") and cleanLine.endswith(";") and \
         cleanLine.count('(') == 1 and cleanLine.count(')') == 1:
        cleanLine = cleanLine.replace("\t","")
        cleanLine = cleanLine.replace(" ","")
        res["testFunctions"].append(cleanLine[14:-2])
    else:
      if cleanLine.startswith("namespace "):
        # assume test functions are not in a namespace
        #refLevel = refLevel+1
        pass
      
      openPaCount = cleanLine.count('(')
      closePaCount = cleanLine.count(')')
      
      if currentLevel == refLevel and openPaCount > 0 and openPaCount == closePaCount:
        # more cleaning...
        cleanLine = cleanLine.replace(" (","(")
        cleanLine = cleanLine.replace("( ","(")
        cleanLine = cleanLine.replace(" )",")")
        cleanLine = cleanLine.replace(") ",")")
        cleanLine = cleanLine.replace(", ",",")
        cleanLine = cleanLine.replace(" ,",",")
        
        matchMain = mainRe.match(cleanLine)
        matchFunc = funcRe.match(cleanLine)
        matchShort = shortRe.match(cleanLine)
        
        if (matchMain != None):
          res["hasMain"] = True
          res["testFunctions"].append("main")
        elif (matchFunc != None) and (len(matchFunc.groups()) == 1):
          res["testFunctions"].append(matchFunc.group(1))
        elif (previousLine == "int") and (matchShort != None) and (len(matchShort.groups()) == 1):
          res["testFunctions"].append(matchShort.group(1))
      # track indentation level
      openBrCount = cleanLine.count('{')
      closeBrCount = cleanLine.count('}')
      currentLevel = currentLevel + openBrCount - closeBrCount
    
    previousLine = line.strip(" \t\n\r")
  
  fd.close()
  return res

def getTestDependencies(includes,sourceList):
  depList = {}
  thirdPartyDep = []
  for inc in includes:
    if inc[0:3] in ["itk","vcl","vnl"]:
      # no extra dependency 
      continue
    elif inc[0:3] == "otb" and inc[3] != '_':
      if inc in sourceList.keys():
        if not sourceList[inc] in depList:
          depList[sourceList[inc]] = {"to":inc}
      else:
        print "Warning ! OTB source not found : "+inc
    else:
      # try an external dependency
      depName = manifestParser.findExternalDep(inc)
      if depName == "Other":
        print "Warning ! Unkown include : "+inc
      elif not depName in thirdPartyDep:
        thirdPartyDep.append(depName)
  
  return [depList,thirdPartyDep]


def buildOldFolderPartition(moduleList):
  partition = {}
  for mod in moduleList:
    for src in moduleList[mod]:
      baseDir = op.split(src)[0]
      if not partition.has_key(baseDir):
        partition[baseDir] = {}
      if not partition[baseDir].has_key(mod):
        partition[baseDir][mod] = 0
      partition[baseDir][mod] = partition[baseDir][mod] + 1
  
  return partition


def findClosestSourceName(testFile,sourceList):
  matchFile = ""
  matchPercent = -1.0
  
  testFileLower = op.splitext(testFile.lower())[0]
  
  if testFileLower.endswith("test"):
    testFileLower = testFileLower[0:-4]
  
  if testFileLower.endswith("example"):
    testFileLower = testFileLower[0:-7]
  
  # handle Fa test name : replace '0004526-' by 'otb'
  faSearchString = r'^[0-9]+-(.+)$'
  faRe = re.compile(faSearchString)
  faMatch = faRe.match(testFileLower)
  if (faMatch != None) and (len(faMatch.groups()) == 1):
    testFileLower = "otb"+faMatch.group(1)
  
  # prefix 'otb' if not present
  if not testFileLower.startswith("otb"):
    testFileLower = "otb"+testFileLower
  
  for src in sourceList:
    srcLower = op.splitext(src.lower())[0]
    minLength = min(len(testFileLower),len(srcLower))
    maxLength = max(len(testFileLower),len(srcLower))
    currentPos = 0
    while (currentPos<minLength):
      if srcLower[currentPos] == testFileLower[currentPos]:
        currentPos = currentPos + 1
      else:
        break
    # take into account length difference between 2 names
    score = 100.0 * float(currentPos) / float(maxLength)
    
    if score > matchPercent:
      matchFile = src
      matchPercent = score
    
  return [matchFile,matchPercent]


def getGroup(module,groups):
  myGroup = ""
  for grp in groups:
    if module in groups[grp]:
      myGroup = grp
      break
  return myGroup


def gatherTestDepends(testCxx,fullDepList):
  gatherTestDependencies = {}
  for tfile in testCxx:
    tmod = testCxx[tfile]["module"]
    if tmod == "TBD":
      continue
    if not tmod in gatherTestDependencies:
      gatherTestDependencies[tmod] = {}
    for tdep in testCxx[tfile]["depList"]:
      # skip module itself and its dependencies
      if (tdep == tmod):
        continue
      if (tmod in fullDepList) and (tdep in fullDepList[tmod]):
        continue
      if not gatherTestDependencies[tmod].has_key(tdep):
        gatherTestDependencies[tmod][tdep] = []
      gatherTestDependencies[tmod][tdep].append(testCxx[tfile]["depList"][tdep])
  return gatherTestDependencies


def main(argv):
  manifestPath = op.expanduser(argv[1])
  moduleDepPath = op.expanduser(argv[2])
  otbDir = op.expanduser(argv[3])
  outManifest = argv[4]
  
  if len(argv) >= 6:
    csvTestDepends = argv[5]
  else:
    csvTestDepends = None
  
  testing_dir = op.join(otbDir,"Testing")
  
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
  
  OldFolderPartition = buildOldFolderPartition(moduleList)
  
  testCxx = {}
  
  outFD = open(outManifest,'wb')
  outFD.write("# Monolithic path, Current dir, group name, module name, subDir name, comment\n")
  
  # parse all cxx test files : analyse them and extract their dependencies
  for (d,f) in codeParser.FindBinaries(testing_dir):
    fullPath = op.join(d,f)
    shortPath = fullPath.replace(otbDir,'.')
    
    # skip Testing/Utilities , will not be used anymore
    if shortPath.startswith("./Testing/Utilities/"):
      continue
    
    moduleDestination = "TBD"
    groupDestination = "TBD"
    
    res = parseTestCxx(fullPath)
    
    if res["isTestDriver"]:
      # no need to dispatch test drivers, they can be generated again
      continue
    
    [testDepList,thirdPartyDep] = getTestDependencies(res["includes"],sourceList)
    
    # try to clean the dependency list (remove inherited modules)
    ignoreModules = ["ImageIO","VectorDataIO","TestKernel"]
    cleanTestDepList = []
    depListToRemove = []
    for dep1 in testDepList:
      # register the "from" field
      testDepList[dep1]["from"] = shortPath
      
      for dep2 in testDepList:
        if dep2 == dep1:
          continue
        # avoid IO modules to 'eat' usefull dependencies
        if dep1 in ignoreModules:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in testDepList:
      if not dep in depListToRemove:
        cleanTestDepList.append(dep)
    
    # build all dependencies of the test
    testFullDepList = []
    for dep in testDepList:
      for subDep in fullDepList[dep]:
        if not subDep in testFullDepList:
          testFullDepList.append(subDep)
    
    # start guessing
    luckyGuess = None
    guessStep = 1
    
    # try to get the list of module used to partition the corresponding source directory
    guessModules = []
    guessSourceDir = op.split(shortPath.replace("./Testing","."))[0]
    if OldFolderPartition.has_key(guessSourceDir):
      guessModules = OldFolderPartition[guessSourceDir].keys()
    
    # special case for Testing/Application  -> ApplicationEngine
    if guessSourceDir == "./Applications":
      guessModules.append("ApplicationEngine")
    
    # first filter : find modules that appear in cleanTestDepList and in guessModules
    overlappingModules = []
    for dep in cleanTestDepList:
      if dep in guessModules:
        overlappingModules.append(dep)
    if len(overlappingModules) == 1:
      luckyGuess = overlappingModules[0]
    
    # second filter : find the source file with the closest name
    if not luckyGuess:
      guessStep += 1
      [matchFile, matchPercent] = findClosestSourceName(f,sourceList)
      if (sourceList[matchFile] in testDepList) and (matchPercent > 50.0):
        luckyGuess = sourceList[matchFile]
      elif (sourceList[matchFile] in testFullDepList) and (matchPercent > 70.0):
        luckyGuess = sourceList[matchFile]
    
    # third filter : ThirdParty
    if not luckyGuess:
      guessStep += 1
      if guessSourceDir == "./Utilities" or len(testDepList) == 0:
        groupDestination = "ThirdParty"
        if len(thirdPartyDep) == 1:
          luckyGuess = thirdPartyDep[0]
    
    # fourth filter : if there is only one dependency in cleanTestDepList : take it
    if not luckyGuess:
      guessStep += 1
      if len(cleanTestDepList) == 1:
        luckyGuess = cleanTestDepList[0]
    
    # fifth filter : separate IO test from non-IO test
    if not luckyGuess:
      guessStep += 1
      if (f.find("Reader") >= 0) or (f.find("Reading") >= 0) or \
         (f.find("Write") >= 0) or (f.find("Writing") >= 0) or \
         (f.find("ImageIO") >= 0) or (guessSourceDir == "./Code/IO"):
        # remove non-IO deps from cleanTestDepList and look what's left
        ioCleanDep = []
        for dep in cleanTestDepList:
          if getGroup(dep,groups) == "IO":
            ioCleanDep.append(dep)
        # ImageIO should be low priority compared to other IO modules
        if (len(ioCleanDep) == 2) and ("ImageIO" in ioCleanDep):
          ioCleanDep.remove("ImageIO")
        if len(ioCleanDep) == 1:
          luckyGuess = ioCleanDep[0]
      else:
        # remove non-IO deps from cleanTestDepList and look what's left
        nonIOcleanDep = []
        for dep in cleanTestDepList:
          if getGroup(dep,groups) != "IO":
            nonIOcleanDep.append(dep)
        if len(nonIOcleanDep) == 1:
          luckyGuess = nonIOcleanDep[0]
        elif len(nonIOcleanDep) == 2:
          # compare the 2 possible modules based on their group
          groupAandB = [getGroup(nonIOcleanDep[0],groups),getGroup(nonIOcleanDep[1],groups)]
          levelAandB = [0,0]
          for idx in [0,1]:
            if groupAandB[idx] == "Core":
              levelAandB[idx] = 1
            elif groupAandB[idx] == "Filtering":
              levelAandB[idx] = 2
            else:
              levelAandB[idx] = 3
          if levelAandB[0] > levelAandB[1]:
            luckyGuess = nonIOcleanDep[0]
          if levelAandB[0] < levelAandB[1]:
            luckyGuess = nonIOcleanDep[1]  
    
    if luckyGuess:
      moduleDestination = luckyGuess
    else:
      pass
      #print f + " -> " + str(testDepList)
      #print f + " -> "+ matchFile + " ( " + str(matchPercent) + "% )"
    
    # if module is found and not group, deduce group
    if groupDestination == "TBD" and moduleDestination != "TBD":
      groupDestination = getGroup(moduleDestination,groups)
    
    if not res["hasMain"]:
      # manually add dependency to TestKernel for cxx using a test driver
      # the include to otbTestMain.h header is not located in the cxx
      testDepList["TestKernel"] = {"from":shortPath ,"to":"./Code/Testing/otbTestMain.h"}
    
    testCxx[shortPath] = {"depList":testDepList , "thirdPartyDep":thirdPartyDep, "group":groupDestination, "module":moduleDestination}
    outFD.write(shortPath+","+op.basename(op.dirname(shortPath))+","+groupDestination+","+moduleDestination+",test,\n")
  
  outFD.close()
  
  # sum all test dependencies in every module
  allTestDepends = gatherTestDepends(testCxx,fullDepList)
  
  # clean the test depends (i.e. ImageIO is dragged by TestKernel)
  cleanTestDepends = {}
  for mod in allTestDepends:
    cleanTestDepends[mod] = {}
    for dep1 in allTestDepends[mod]:
      isClean = True
      for dep2 in allTestDepends[mod]:
        if dep1 == dep2:
          continue
        if dep1 in fullDepList[dep2]:
          isClean = False
          break
      if isClean:
        cleanTestDepends[mod][dep1] = 1
  
  
  if csvTestDepends:
    manifestParser.outputCSVEdgeList(cleanTestDepends,csvTestDepends)
  
  #manifestParser.printDepList(allTestDepends)


if __name__ == "__main__":
  if len(sys.argv) < 5 :
    showHelp()
  else:
    main(sys.argv)
