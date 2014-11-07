#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import re


def showHelp():
  print "Usage : createTestManifest.py  MANIFEST_FILE.csv  OTB_SRC_DIRECTORY  OUTPUT_TEST_MANIFEST"

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
      cleanLine = cleanLine[comment1Pos:]
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
  
  testFileLower = testFile.lower()
  
  for src in sourceList:
    srcLower = src.lower()
    maxLength = min(len(testFileLower),len(srcLower))
    currentPos = 0
    while (currentPos<maxLength):
      if srcLower[currentPos] == testFileLower[currentPos]:
        currentPos = currentPos + 1
      else:
        break
    score = 100.0 * float(currentPos) / float(len(testFile))
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


def gatherTestDepends(testMains,testFunctions,fullDepList):
  gatherTestDependencies = {}
  for tfile in testMains:
    tmod = testMains[tfile]["module"]
    if tmod == "TBD":
      continue
    if not tmod in gatherTestDependencies:
      gatherTestDependencies[tmod] = {}
    for tdep in testMains[tfile]["depList"]:
      # skip module itself and its dependencies
      if (tdep == tmod) or (tdep in fullDepList[tmod]):
        continue
      if not gatherTestDependencies[tmod].has_key(tdep):
        gatherTestDependencies[tmod][tdep] = []
      gatherTestDependencies[tmod][tdep].append(testMains[tfile]["depList"][tdep])
  for tfile in testFunctions:
    tmod = testFunctions[tfile]["module"]
    if tmod == "TBD":
      continue
    if not tmod in gatherTestDependencies:
      gatherTestDependencies[tmod] = {}
    for tdep in testFunctions[tfile]["depList"]:
      # skip module itself and its dependencies
      if (tdep == tmod) or (tdep in fullDepList[tmod]):
        continue
      if not gatherTestDependencies[tmod].has_key(tdep):
        gatherTestDependencies[tmod][tdep] = []
      gatherTestDependencies[tmod][tdep].append(testFunctions[tfile]["depList"][tdep])
  
  return gatherTestDependencies


def main(argv):
  manifestPath = op.expanduser(argv[1])
  otbDir = op.expanduser(argv[2])
  outManifest = argv[3]
  
  testing_dir = op.join(otbDir,"Testing")
  
  # Standard Manifest parsing, extract simple and full dependencies
  [groups,moduleList,sourceList] = manifestParser.parseManifest(manifestPath)
  depList = manifestParser.buildSimpleDep(otbDir,moduleList,sourceList)
  fullDepList = manifestParser.buildFullDep(depList)
  
  OldFolderPartition = buildOldFolderPartition(moduleList)
  
  testDrivers = {}
  testMains = {}
  testFunctions = {}
  
  outFD = open(outManifest,'wb')
  
  # parse all cxx test files : analyse them and extract their dependencies
  for (d,f) in codeParser.FindBinaries(testing_dir):
    fullPath = op.join(d,f)
    shortPath = fullPath.replace(otbDir,'.')
    
    moduleDestination = "TBD"
    groupDestination = "TBD"
    
    res = parseTestCxx(fullPath)
    
    if res["isTestDriver"]:
      # no need to dispatch test drivers, they can be generated again
      testDrivers[shortPath] = res["testFunctions"]
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
    firstLuckyGuess = None
    for dep in cleanTestDepList:
      if dep in guessModules:
        overlappingModules.append(dep)
    if len(overlappingModules) == 1:
      firstLuckyGuess = overlappingModules[0]
    
    # second filter : find the source file with the closest name
    secondLuckyGuess = None
    [matchFile, matchPercent] = findClosestSourceName(f,sourceList)
    if (sourceList[matchFile] in testDepList) and (matchPercent > 50.0):
      secondLuckyGuess = sourceList[matchFile]
    elif (sourceList[matchFile] in testFullDepList) and (matchPercent > 70.0):
      secondLuckyGuess = sourceList[matchFile]
    
    # third filter : Utilities
    thirdLuckyGuess = None
    if guessSourceDir == "./Utilities":
      groupDestination = "ThirdParty"
      if len(thirdPartyDep) == 1:
        thirdLuckyGuess = thirdPartyDep[0]
    
    # fourth filter : if there is only one dependency in cleanTestDepList : take it
    fourthLuckyGuess = None
    if len(cleanTestDepList) == 1:
      fourthLuckyGuess = cleanTestDepList[0]
    
    # fifth filter : handle test containing "Reader" "Writer" ...
    fifthLuckyGuess = None
    if (f.find("Reader") >= 0) or (f.find("Reading") >= 0) or \
       (f.find("Writer") >= 0) or (f.find("Writing") >= 0):
      # remove non-IO deps from cleanTestDepList and look what's left
      ioCleanDep = []
      for dep in cleanTestDepList:
        if getGroup(dep,groups) == "IO":
          ioCleanDep.append(dep)
      if len(ioCleanDep) == 1:
        fifthLuckyGuess = ioCleanDep[0]
    
    
    if firstLuckyGuess:
      moduleDestination = firstLuckyGuess
    elif secondLuckyGuess:
      moduleDestination = secondLuckyGuess
    elif thirdLuckyGuess:
      moduleDestination = thirdLuckyGuess
    elif fourthLuckyGuess:
      moduleDestination = fourthLuckyGuess
    elif fifthLuckyGuess:
      moduleDestination = fifthLuckyGuess
    else:
      pass
      #print f + " -> " + str(testDepList)
      #print f + " -> "+ matchFile + " ( " + str(matchPercent) + "% )"
    
    # if module is found and not group, deduce group
    if groupDestination == "TBD" and moduleDestination != "TBD":
      groupDestination = getGroup(moduleDestination,groups)
    
    
    outputDic = {"depList":testDepList , "thirdPartyDep":thirdPartyDep, "group":groupDestination, "module":moduleDestination}
    
    if res["hasMain"]:
      testMains[shortPath] = outputDic
    else:
      outputDic["testFunctions"] = res["testFunctions"]
      testFunctions[shortPath] = outputDic
    
    outFD.write(shortPath+","+op.basename(op.dirname(shortPath))+","+groupDestination+","+moduleDestination+",test,\n")
  
  outFD.close()
  
  # sum all test dependencies in every module
  allTestDepends = gatherTestDepends(testMains,testFunctions,fullDepList)
  
  # clean inherited test depends
  cleanedTestDepends = {}
  for mod in allTestDepends:
    cleanList = []
    depListToRemove = []
    for dep1 in allTestDepends[mod]:
      for dep2 in allTestDepends[mod]:
        if dep2 == dep1:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in allTestDepends[mod]:
      if not dep in depListToRemove:
        cleanList.append(dep)
    cleanedTestDepends[mod] = cleanList
  
  
  manifestParser.printDepList(allTestDepends)
  """
  for mod in allTestDepends:
    print "---------------------------------------"
    print "Module "+mod
    for dep in allTestDepends[mod]:
      print "  -> "+dep
      for tfile in allTestDepends[mod][dep]:
        print "    * "+tfile
  """  
  # DEBUG  
  return
  
  
  
  # Get test list ( except application tests)
  testing_dir = op.join(otbDir,"Testing")
  test_count = 0
  tests_map = {}
  for (d,f) in codeParser.Find(testing_dir,"CMakeLists.txt"):
    tests = codeParser.ParseAddTests(op.join(d,f))
    test_count = test_count + len(tests)
    
    for (testName,testCode) in tests:
      # for each testName, extract its corresponding "test_function_name" as called in add_test()
      #testFunctionName = extractTestFunctionName(testCode)
      #print testName + "\t\t->" + testFunctionName
      pass
      
      # store each test name with usefull informations
  

if __name__ == "__main__":
  if len(sys.argv) < 3 :
    showHelp()
  else:
    main(sys.argv)
