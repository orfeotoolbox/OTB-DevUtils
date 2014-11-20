#!/usr/bin/python
#==========================================================================
#
#   Copyright Insight Software Consortium
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0.txt
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#==========================================================================*/
# This script is used to automate the modularization process. The following
# steps  are included:
# 1. Move the files in the monolithic ITK into modules of the modularized ITK.
#    A manifest text file that lists all the files and their destinations is
#    required to run the script.By default, the manifest file is named as
#    "Manifest.txt" in the  same directory of this script.
# 2. Create CMake Files and put them into modules.

# Modified by Guillaume Pasero <guillaume.pasero@c-s.fr>
# add dependencies in otb-module.cmake

# To run it, type ./modulizer.py  OTB_PATH  Manifest_PATH
# from the otb-modulizer root directory.

print "*************************************************************************"
print "WARNINGs! This modularization script is still in its experimental stage."
print "Current OTB users should not run this script."
print "*************************************************************************"


import shutil
import os.path as op
import re
import sys
import os
import stat
import glob
import documentationCheck

def parseFullManifest(path):
  sourceList = []
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
    return sourceList
  
  # parse file
  for line in fd:
    words = line.split(sep)
    if (len(words) < (nbFields-1)):
      print "Wrong number of fields, skipping this line"
      continue
    fullPath = words[0].strip(" ,;\t\n\r")
    groupName = words[2].strip(" ,;\t\n\r")
    moduleName = words[3].strip(" ,;\t\n\r")
    subDir = words[4].strip(" ,;\t\n\r")
    sourceName = op.basename(fullPath)
    
    sourceList.append({"path":fullPath, "group":groupName, "module":moduleName, "subDir":subDir})
  fd.close()
  
  return sourceList


if len(sys.argv) < 4:
    print("USAGE:  {0}  monolithic_OTB_PATH  OUTPUT_DIR  Manifest_Path  [module_dep [test_dep]]".format(sys.argv[0]))
    print("  monolithic_OTB_PATH : checkout of OTB repository (will not be modified)")
    print("  OUTPUT_DIR          : output directory where OTB_Modular and OTB_remaining will be created ")
    print("  Manifest_Path       : path to manifest file, in CSV-like format. Fields are :")
    print("                          source_path/current_subDir/group/module/subDir/comment")
    print("  module_dep          : dependencies between modules")
    print("  test_dep            : additional dependencies for tests")
    sys.exit(-1)

scriptDir = op.dirname(op.abspath(sys.argv[0]))

HeadOfOTBTree = sys.argv[1]
if (HeadOfOTBTree[-1] == '/'):
    HeadOfOTBTree = HeadOfOTBTree[0:-1]

OutputDir = sys.argv[2]
HeadOfModularOTBTree = op.join(OutputDir,"OTB_Modular")

ManifestPath = sys.argv[3]

EdgePath = ""
if len(sys.argv) >= 5:
  EdgePath = sys.argv[4]
  
testDependPath = ""
if len(sys.argv) >= 6:
  testDependPath = sys.argv[5]

# copy the whole OTB tree over to a temporary dir
HeadOfTempTree = op.join(OutputDir,"OTB_remaining")

if op.isdir(HeadOfTempTree):
    shutil.rmtree(HeadOfTempTree)

if op.isdir(HeadOfModularOTBTree):
    shutil.rmtree(HeadOfModularOTBTree)

print("Start to copy" + HeadOfOTBTree + " to  ./OTB_remaining ...")
shutil.copytree(HeadOfOTBTree,HeadOfTempTree, ignore = shutil.ignore_patterns('.hg','.hg*'))
print("Done copying!")

# checkout OTB-Modular
cmd ='hg clone http://hg.orfeo-toolbox.org/OTB-Modular  '+HeadOfModularOTBTree
os.system(cmd)

logDir = op.join(OutputDir,"logs")
if not op.isdir(logDir):
  os.makedirs(logDir)

# read the manifest file
print ("moving files from ./OTB_remaining into modules in {0}".format(HeadOfModularOTBTree))
numOfMissingFiles = 0;
missingf =  open(op.join(logDir,'missingFiles.log'),'w')
moduleList=[]
moduleDic={}
sourceList = parseFullManifest(ManifestPath)

for source in sourceList:
  # build module list
  moduleDic[source["module"]] = source["group"]
  
  # create the path
  inputfile = op.abspath(op.join(HeadOfTempTree,source["path"]))
  outputPath = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(source["group"],op.join(source["module"],source["subDir"])))
  if not op.isdir(outputPath):
    os.makedirs(outputPath)
  
  # copying files to the destination
  if  op.isfile(inputfile):
    if op.isfile(op.join(outputPath,op.basename(inputfile))):
      os.remove(op.join(outputPath,op.basename(inputfile)))
    shutil.move(inputfile, outputPath)
  else:
    missingf.write(inputfile+'\n')
    numOfMissingFiles = numOfMissingFiles + 1

missingf.close()
print ("listed {0} missing files to logs/missingFiles.log").format(numOfMissingFiles)

moduleList = moduleDic.keys()

# after move, operate a documentation check
for source in sourceList:
  outputPath = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(source["group"],op.join(source["module"],source["subDir"])))
  outputFile = op.join(outputPath,op.basename(source["path"]))
  if  op.isfile(outputFile):
    if op.splitext(outputFile)[1] == ".h":
      nextContent = documentationCheck.parserHeader(outputFile,source["module"])
      fd = open(outputFile,'wb')
      fd.writelines(nextContent)
      fd.close()


# get dependencies (if file is present)
dependencies = {}
testDependencies = {}
for mod in moduleList:
  dependencies[mod] = []
  testDependencies[mod] = []

if op.isfile(EdgePath):
  fd = open(EdgePath,'rb')
  for line in fd:
    words = line.split(',')
    if len(words) == 2:
      depFrom = words[0].strip(" ,;\t\n\r")
      depTo = words[1].strip(" ,;\t\n\r")
      if dependencies.has_key(depFrom):
        dependencies[depFrom].append(depTo)
      else:
        print("Bad dependency : "+depFrom+" -> "+depTo)
  fd.close()

if op.isfile(testDependPath):
  fd = open(testDependPath,'rb')
  for line in fd:
    words = line.split(',')
    if len(words) == 2:
      depFrom = words[0].strip(" ,;\t\n\r")
      depTo = words[1].strip(" ,;\t\n\r")
      if testDependencies.has_key(depFrom):
        testDependencies[depFrom].append(depTo)
      else:
        print("Bad dependency : "+depFrom+" -> "+depTo)
  fd.close()


# list the new files
newf =  open(op.join(logDir,'newFiles.log'),'w')
for (root, subDirs, files) in os.walk(HeadOfTempTree):
   for afile in files:
     newf.write(op.join(root, afile)+'\n')
newf.close()
print ("listed new files to logs/newFiles.log")

###########################################################################

print ('creating cmake files for each module (from the template module)')
#moduleList = os.listdir(HeadOfModularOTBTree)
for  moduleName in moduleList:
  moduleDir = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(moduleDic[moduleName],moduleName))
  cmakeModName = "OTB"+moduleName
  
  if op.isdir(moduleDir):
     
    # write CMakeLists.txt
    filepath = moduleDir+'/CMakeLists.txt'
    if not op.isfile(filepath):
      o = open(filepath,'w')
      for line in open(op.join(scriptDir,'templateModule/otb-template-module/CMakeLists.txt'),'r'):
          line = line.replace('otb-template-module',cmakeModName)
          o.write(line);
      o.close()

    # write src/CMakeLists.txt
    # list of CXX files
    if op.isdir(moduleDir+'/src'):
      cxxFiles = glob.glob(moduleDir+'/src/*.cxx')
      cxxFileList='';
      for cxxf in cxxFiles:
          cxxFileList = cxxFileList+'  '+cxxf.split('/')[-1]+'\n'
      # build list of link dependencies
      linkLibs = ""
      for dep in dependencies[moduleName]:
        linkLibs = linkLibs + "  ${OTB"+dep+"_LIBRARIES}" + "\n"
      if len(linkLibs) == 0:
        linkLibs = " ${OTBITK_LIBRARIES}"
      filepath = moduleDir+'/src/CMakeLists.txt'
      if not op.isfile(filepath):
        o = open(filepath,'w')
        for line in open(op.join(scriptDir,'templateModule/otb-template-module/src/CMakeLists.txt'),'r'):
          line = line.replace('otb-template-module',cmakeModName)
          line = line.replace('LIST_OF_CXX_FILES',cxxFileList[0:-1]) #get rid of the last \n
          line = line.replace('LINK_LIBRARIES_TO_BE_REPLACED',linkLibs)
          o.write(line);
        o.close()

    # write  test/CMakeLists.txt
    """
    if op.isdir(moduleDir+'/test'):
      cxxFiles = glob.glob(moduleDir+'/test/*.cxx')
      cxxFileList='';
      for cxxf in cxxFiles:
           cxxFileList = cxxFileList+cxxf.split('/')[-1]+'\n'
      filepath = moduleDir+'/test/CMakeLists.txt'
      if not op.isfile(filepath):
          o = open(filepath,'w')
          for line in open('./templateModule/otb-template-module/test/CMakeLists.txt','r'):
             # TODO : refactor for OTB
             words= moduleName.split('-')
             moduleNameMod='';
             for word in words:
                moduleNameMod=moduleNameMod + word.capitalize()
             line = line.replace('itkTemplateModule',moduleNameMod)
             line = line.replace('itk-template-module',moduleName)
             line = line.replace('LIST_OF_CXX_FILES',cxxFileList[0:-1]) #get rid of the last \n
             o.write(line);
          o.close()
    """
    
    # write otb-module.cmake, which contains dependency info
    filepath = moduleDir+'/otb-module.cmake'
    if not op.isfile(filepath):
      o = open(filepath,'w')
      for line in open(op.join(scriptDir,'templateModule/otb-template-module/otb-module.cmake'),'r'):
        # replace module name
        line = line.replace('otb-template-module',cmakeModName)
        # replace depend list
        dependTagPos = line.find("DEPENDS_TO_BE_REPLACED")
        if dependTagPos >= 0:
          replacementStr = "DEPENDS"
          if len(dependencies[moduleName]) > 0:
            indentStr = ""
            for it in range(dependTagPos+2):
              indentStr = indentStr + " "
            for dep in dependencies[moduleName]:
              replacementStr = replacementStr + "\n" + indentStr +"  OTB"+ dep
          else:
            replacementStr = replacementStr + "\n" + indentStr + "  OTBCommon"
          line = line.replace('DEPENDS_TO_BE_REPLACED',replacementStr)
        # replace test_depend list
        testDependTagPos = line.find("TESTDEP_TO_BE_REPLACED")
        if testDependTagPos >= 0:
          if len(testDependencies[moduleName]) > 0:
            indentStr = ""
            replacementStr = "TEST_DEPENDS"
            for it in range(testDependTagPos+2):
              indentStr = indentStr + " "
            for dep in testDependencies[moduleName]:
              replacementStr = replacementStr + "\n" + indentStr +"OTB"+ dep  
            line = line.replace('TESTDEP_TO_BE_REPLACED',replacementStr)
          else:
            line = line.replace('TESTDEP_TO_BE_REPLACED','')
        o.write(line);
      o.close()

# save version without patches (so that we can regenerate patches later)
os.system( "cp -ar " + op.join(OutputDir,"OTB_Modular") + " " + op.join(OutputDir,"OTB_Modular-nopatch") )

# apply patches in OTB_Modular
curdir = os.path.dirname(__file__)
os.system( "cd " + op.join(OutputDir,"OTB_Modular") + " && patch -p1 < " + curdir + "/patches/otbmodular.patch")

