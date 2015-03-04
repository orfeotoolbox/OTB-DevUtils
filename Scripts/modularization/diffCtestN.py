#!/usr/bin/python

import os
import re
import os.path as op
import sys

def FindProblematicTests(otb_dir):
    re_str = "[a-z][a-z]T[a-z][A-Za-z0-9_\-]*[$\{[A-Za-z0-9_\-]+\}][A-Za-z0-9_\-]*"

    testdir = op.join(otb_dir,"Testing")
    for d in os.listdir(testdir):
        cmakefile = op.join(testdir,d,"CMakeLists.txt")
        f = open(cmakefile,'rb')
        for line in open(cmakefile):
            if re.search(re_str,line):
                print line
        

def parseCtestN(file):
    f = open(file,'rb')

    out = set()
    todo = set()
    regex = " *Test +#[0-9]+: "
    regex2 = "[a-z][a-z]TvDocAppli_[A-Za-z0-9]+|[a-z][a-z]TvQtWidgetShow_[A-Za-z0-9]+"
    
    for line in f:
        cleanline = (line.replace("\t"," ")).strip(" \n\r")
        if re.search(regex,cleanline):
            test = re.sub(regex,'',cleanline).strip("\n")
            if not test.endswith("DoxygenGroup") and not test.startswith("ut"):
                if not re.search(regex2,cleanline):
                    out.add(test)
                else:
                    todo.add(test)
        else:
            print "No test found in line: "+cleanline
    return todo,out


if len(sys.argv) != 3:
    print "Compares the output of two ctest -N >> file command, to see differences in tests run"
    print "Usage: "+sys.argv[0]+" file1 file2"
    sys.exit()

ctest1 = op.abspath(sys.argv[1])
ctest2 = op.abspath(sys.argv[2])

todo1,ctest_set1 = parseCtestN(ctest1)
todo2,ctest_set2 = parseCtestN(ctest2)

removed = ctest_set1 - ctest_set2
added = ctest_set2 - ctest_set1

print "\n"+str(len(todo1))+" tests are already identified as missing: \n"

for t in sorted(todo1):
    print t

print "\n"+str(len(removed))+" tests found in "+ctest1+" but not in "+ctest2+"\n"

for diff in sorted(removed):
    print diff

print "\n"+str(len(added))+" tests found in "+ctest2+" but not in "+ctest1+"\n"

for diff in sorted(added):
    print diff

