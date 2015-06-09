#!/usr/bin/python
"""
Script to fix incomplete tagfiles for doxygen generation.

Some tagfile (such as ITK doxygen tagfile) have misplaced members :
those members (function, typedef or variables) are not placed in the
right class description ('compound' element, with 'kind=class').  

This script uses the 'anchorfile' of each class member to check if 
it is in the right class description. The fixed tagfile is written 
in a new file. 
"""

import sys
import xml.etree.ElementTree as ET

def findClassCompound(root, fileName):
  for elem in root.findall('compound'):
    if elem.get('kind') == 'class':
      if elem.find('filename').text == fileName:
        return elem
  return 0
  
def hasMember(compound, name, anchorfile, anchor):
  for member in compound.findall('member'):
    if (member.find('name').text == name) and \
       (member.find('anchorfile').text == anchorfile) and \
       (member.find('anchor').text == anchor):
      return True
  return False

def main(argv):
  if len(argv) < 3:
    print("Fix tagfiles for doxygen generation")
    print("Usage : "+argv[0]+" input.tag  output.tag")
    return 1
    
  inputPath = argv[1]
  outputPath = argv[2]
  
  tree = ET.parse(inputPath)
  root = tree.getroot()
  
  for elem in root.findall('compound'):
    if elem.get('kind') != 'class':
      continue
    currentDoxPage = elem.find('filename').text
    for member in elem.findall('member'):
      anchorFile = member.find('anchorfile').text
      if anchorFile.endswith('.html') and anchorFile != currentDoxPage:
        #print("Difference : "+member.find('name').text+" ; "+currentDoxPage+" vs "+anchorFile)
        # found a misplaced member, try to relocate it
        targetCompound = findClassCompound(root,anchorFile)
        if targetCompound == 0:
          print("Warning: file not found : "+anchorFile)
          continue
        
        curName = member.find('name').text
        curAnchor = member.find('anchor').text
        
        # remove it from original compound
        elem.remove(member)
        if not hasMember(targetCompound, curName, anchorFile, curAnchor):
          # relocate to the right compound
          targetCompound.append(member)
  
  tree.write(outputPath)

if __name__ == "__main__":
  main(sys.argv)  
