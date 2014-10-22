#!/usr/bin/python
#coding=utf8
import fileinput, glob, string, sys, os, stat

# list all files in directory
def RecursiveDirectoriesListing(top="."):
	""" List directories recursively"""
	names = os.listdir(top)
	files = []
	for name in names:
		try:
			st = os.lstat(os.path.join(top,name))
		except os.error:
			continue
		if stat.S_ISDIR(st.st_mode):
		    for(newtop,children) in RecursiveDirectoriesListing(os.path.join(top,name)):
			yield newtop,children
		else:
		    files.append(name)
			
	yield top,files

# Grep a key from a filename
def Grep(filename,key):
    ifstream = open(filename,'r')
    lines = ifstream.readlines()
    ifstream.close()
    
    resp = []
    count=1
    for line in lines:
        if line.count(key):
            resp.append(count)
        count+=1
    return resp


def Find(directory,name):
    resp = []
    for (currentDirectory,files) in RecursiveDirectoriesListing(directory):
        for currentFile in files:
            if currentFile == name:
                resp.append((currentDirectory,currentFile))
    return resp

def FindHeaders(directory):
    resp = []
    for (currentDirectory,files) in RecursiveDirectoriesListing(directory):
        for currentFile in files:
            if currentFile.endswith(".h"):
                resp.append((currentDirectory,currentFile))
    return resp


# From a given header, find associated tests binaries
def FindBinariesFromHeader(directory,header):
    resp=[]
    for (currentDirectory,files) in RecursiveDirectoriesListing(directory):
        for currentFile in files:
            if currentFile.endswith(".cxx"):
                occ = Grep(os.path.join(currentDirectory,currentFile),header)
                if len(occ)>0:
                    resp.append((currentDirectory,currentFile))
    return resp

def FindTestsCommands(filename):
    resp = []
    ifstream = open(filename,'r')
    lines = ifstream.readlines()
    ifstream.close()

    for line in lines:
        if line.count("argv[]"):
            try:
                start = string.index(line,"int ")
                end = string.index(line,"(")
                resp.append(line[start+4:end])
            except ValueError:
                pass
    return resp

def ParseIncludes(cxx):
    resp = []
    
    ifstream = open(cxx)
    lines = ifstream.readlines()
    ifstream.close()

    for line in lines:
        if line.count('#include "'):
            try:
                start = string.index(line,'#include "')
                end = string.rindex(line,'"')
                if line[start+10:end].startswith("otb"):
                    resp.append(line[start+10:end])
            except ValueError:
                pass
    return resp

def ParseAddTests(cmakefile):

    resp = []

    ifstream = open(cmakefile)
    lines = ifstream.readlines()
    ifstream.close()

    current_test_cmake_code = []
    current_test_name = ""
    in_addtest = False
    for line in lines:
        if line.count("add_test"):      
            in_addtest = True
            try:
                start = string.index(line,"add_test")
                end  = string.index(line," ",start)
                current_test_name = line[start+9:end]
            except ValueError:
                try:
                    start = string.index(line,"add_test")
                    current_test_name = line[start+9:]
                except ValueError:  
                    pass
        if in_addtest:
            current_test_cmake_code.append(line)
        if line.count(")"):
            if in_addtest:
                current_test_name.strip()    
                resp.append((current_test_name, current_test_cmake_code))
            in_addtest = False
            current_test_cmake_code = []
            current_test_name = ""
    return resp

# main
available_commands = {"find_tests","find_examples","find_applications","find_includes", "display_test"}

if(len(sys.argv) < 3 or (len(sys.argv)>2 and sys.argv[1] not in available_commands)):
       print "Usage: "+sys.argv[0]+" command otb_dir param"
       print "Available commands:"
       print "\t find_tests:\t inparam is a header file. Returns a list of all tests using this header, including test directory, test cxx file, test function (in cxx file) and test name"
       print "\t find_examples:\t inparam is a header file. Returns a list of all examples using this header, including example directory and cxx file."
       print "\t find_applications:\t inparam is a header file. Returns a list of all applications using this header, including application directory and cxx file"
       print "\t find_includes:\t inparam is a cxx file (without path). For all cxx test file matching inparam, returns a list otb included headers, and the directory where this include is located"
       print "\t display_test:\t inparam is a test name. Look for test in all tests, and display the CMake code of the test if found."
       sys.exit()

command = sys.argv[1]    
otb_rep = sys.argv[2]
inparam = sys.argv[3]

testing_dir = os.path.join(otb_rep,"Testing")
example_dir = os.path.join(otb_rep,"Examples")
app_dir = os.path.join(otb_rep,"Applications")
code_dir = os.path.join(otb_rep,"Code")

tests_map = {}

print "Building tests map ..."
test_count = 0
for (d,f) in Find(testing_dir,"CMakeLists.txt"):
    tests = ParseAddTests(os.path.join(d,f))
    test_count = test_count + len(tests)
#    print "Found "+str(len(tests))+" in "+os.path.join(d,f)
#    for test,code in tests:
            #print test
    tests_map[d]=tests
print "Done. Parsed "+str(test_count)+" tests."

print "Builidng headers map ..."
headers = FindHeaders(code_dir)
print "Done. Parsed "+str(len(headers))+" headers."


if command == "find_tests":

    tests = FindBinariesFromHeader(testing_dir,inparam)

    print "\n"
    print "Tests using header "+inparam
    
    print "\n"
    for(d,f) in tests:
        tests_name = FindTestsCommands(os.path.join(d,f))
        for t in tests_name:
            for (n,c) in tests_map[d]:
                for line in c:
                    if line.count(t.strip()):
                        print d[len(otb_rep)+14:]+"\t"+f+"\t"+t+"\t"+n
                        break
            
elif command  == "find_examples":
    examples = FindBinariesFromHeader(example_dir,inparam)
    print "\n"
    print "Examples using header "+inparam
    print "\n"
    for(d,f) in examples:
        print d[len(otb_rep)+14:]+"\t"+f

elif command == "find_applications":
    apps = FindBinariesFromHeader(app_dir,inparam)
    print "\n"
    print "Applications using header "+inparam
    print "\n"
    for(d,f) in apps:
        print d[len(otb_rep)+14:]+"\t"+f

elif command == "find_includes":
    binaries = Find(testing_dir,inparam)

    if len(binaries) == 0:
        print inparam+" not found in OTB"
    
    for(d,f) in binaries:
        includes = ParseIncludes(os.path.join(d,f))
        for include in includes:
            for(dd,ff) in headers:
                if include == ff:
                    print d[len(otb_rep)+14:]+"\t"+f+"\t"+dd[len(otb_rep)+6:]+"\t"+include

elif command == "display_test":
    for (k,v) in tests_map.iteritems():
        for (t,c) in v:
            if t.count(inparam):
                print "Found "+inparam+" test in "+k+" :"
                for line in c:
                    print line
