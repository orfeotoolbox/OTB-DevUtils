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
  
  systemInc = ["string.h","stdio.h","stdint.h","ctype.h","dirent.h","assert.h","sys/types.h"]
  
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
  depList = []
  thirdPartyDep = []
  for inc in includes:
    if inc[0:3] in ["itk","vcl","vnl"]:
      # no extra dependency 
      continue
    elif inc[0:3] == "otb":
      if inc in sourceList.keys():
        if not sourceList[inc] in depList:
          depList.append(sourceList[inc])
      else:
        print "Warning ! OTB source not found : "+inc
    else:
      # try an external dependency
      depName = manifestParser.findExternalDep(inc)
      if not depName in thirdPartyDep:
        thirdPartyDep.append(depName)
  
  return (depList,thirdPartyDep)


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
  
  # parse all cxx test files : analyse them and extract their dependencies
  for (d,f) in codeParser.FindBinaries(testing_dir):
    fullPath = op.join(d,f)
    shortPath = fullPath.replace(otbDir,'.')
    
    res = parseTestCxx(fullPath)
    
    [testDepList,thirdPartyDep] = getTestDependencies(res["includes"],sourceList)
    
    # try to clean the dependency list (remove inherited modules)
    cleanTestDepList = []
    depListToRemove = []
    for dep1 in testDepList:
      for dep2 in testDepList:
        if dep2 == dep1:
          continue
        # avoid IOBase to 'eat' usefull dependencies
        if dep1 == "IOBase":
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in testDepList:
      if not dep in depListToRemove:
        cleanTestDepList.append(dep)
    
    # try to get the list of module used to partition the corresponding source directory
    guessModules = []
    guessSourceDir = op.split(shortPath.replace("./Testing","."))[0]
    if OldFolderPartition.has_key(guessSourceDir):
      guessModules = OldFolderPartition[guessSourceDir].keys()
    
    
    # first filter : find modules that appear in cleanTestDepList and 
    firstLuckyGuess = []
    for dep in cleanTestDepList:
      if dep in guessModules:
        firstLuckyGuess.append(dep)
    
    if len(firstLuckyGuess) == 1:
      print f + " -> FIRST_LUCKY_GUESS "+firstLuckyGuess[0]
    else:
      print f + " -> Failed"
    
    
    if res["isTestDriver"]:
      testDrivers[shortPath] = res["testFunctions"]
    elif res["hasMain"]:
      testMains[shortPath] = {"depList":testDepList , "thirdPartyDep":thirdPartyDep }
    else:
      testFunctions[shortPath] = {"depList":testDepList , "thirdPartyDep":thirdPartyDep, "testFunctions":res["testFunctions"] }
    
    #print shortPath+" -> "+str(depList)
    #print f + " -> "+str(res["isTestDriver"])+" / "+str(res["hasMain"])+" / "+str(len(res["testFunctions"]))+" / " +str(len(res["includes"]))
    
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
