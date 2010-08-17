#!/usr/bin/python


# Generate the list of file that do not appear in the coverage report
# 2 parameters are required (just below):
# - the root of the OTB repository
# - the coverage xml file generated during the coverage

otbRoot = "/home/otbtesting/OTB/trunk/OTB-Nightly"
coverageFilename =  "/home/otbtesting/OTB/OTB-Binary-Coverage/Testing/20100815-1800/Coverage.xml"

import os, xml.dom.minidom, fnmatch

# find the files that don't even appear on the dashboard coverage report

# produce the list of files in OTB

otbList = []

def findFiles(basedir, l, relativedir):
    fnames = os.listdir(basedir)
    for fname in fnames:
      if os.path.isdir(os.path.join(basedir, fname)):
        findFiles(os.path.join(basedir, fname), l, os.path.join(relativedir, fname))
      else:
        if fnmatch.fnmatch(fname, '*.cxx') or fnmatch.fnmatch(fname, '*.txx') or fnmatch.fnmatch(fname, '*.h'):
          l.append(os.path.join(relativedir, fname))

findFiles(otbRoot+'/Code', otbList, './Code')
findFiles(otbRoot+'/Testing', otbList, './Testing')

# produce the list of files that appears in the coverage
# using the Coverage.xml produced by the coverage

coveredList = []

doc = xml.dom.minidom.parse(coverageFilename)

for e in doc.childNodes[0].childNodes[1].childNodes:
    if e.localName == "File":
        coveredList.append(e.attributes["FullPath"].value)


# produce the list of files that are in otbList but not in coveredList

diff =  set(otbList).difference(set(coveredList))
diff = sorted(list(diff))
for d in diff:
    print d
