#!/usr/bin/python
#coding=utf8
import fileinput,glob,string,sys,os,stat,shutil
from os.path import join

####### FUNCTIONS ###################
def RecursiveDirectoriesListing(top="."):
	""" List directories recursively"""
	names = os.listdir(top)
	files = []
	for name in names:
		try:
			st = os.lstat(join(top,name))
		except os.error:
			continue
		if stat.S_ISDIR(st.st_mode):
		    for(newtop,children) in RecursiveDirectoriesListing(join(top,name)):
			yield newtop,children
		else:
		    files.append(name)
			
	yield top,files



def TestPb(lines):
	
	if "Checking test dependency graph end" in lines[-1]: #not found
		return 5
	
	for l in lines:
		if "Diff ASCII File" in l:
			return 1
		if "SegFault" in l or "SEGFAULT" in l:
			return 2
		if ".dylib" in l or ".so" in l:
			return 3
		if "100% tests passed" in l:
			return 0
			
	#All other situations
	return 4
	

#Mapping test names / IDs
def mapping(filename,tempfile):
	
	testID=[]
	
	# reading file 
	ifstream = open(filename,'r')
	lines = ifstream.readlines()
	ifstream.close()
	
	testNames=[]
	#for each line 
	for l in lines:
		l=l.replace('\n','')
		if ':' in l:
			sptl=l.split(":")
			testNames.append(sptl[1])
		else:
			testNames.append(l)
			
	#for each test
	for t in testNames:
		command_ctest = 'ctest -R ' + t + ' -N' + ' > ' + temp
		os.system(command_ctest)		
		
		ifstream = open(temp,'r')
		lines = ifstream.readlines()
		ifstream.close()
		
		if lines[-1] != 'Total Tests: 0':
		
			#for each line
			for l in lines:
				if '#' in l:
					firstSplit = l.split('#')
					secondSplit = firstSplit[1].split(':')
					ID = secondSplit[0]
					name = secondSplit[1].replace(' ','')
					name = name.replace('\n','')

					if name == t:
						testID.append(ID)
						#print t,'--->',ID
		else:
			print 'WARNING : test ' + t + ' not found !!'

	return testID
				


# Process tests (by IDs)
def ProcessFile(filename,destfile,tempfile):
	
	sep = '----------------------------- \n'
	
	flags=[[],[],[],[],[],[]]
	
	
	testID = mapping(filename,tempfile)
	
	NbTests = float(len(testID))

	n = 0.0
	ofstream = open(destfile,'a')
	for ID in testID:	
		#command_ctest = 'ctest -I ' + ID + ',' + ID + ' -O ' + temp + ' -VV'
		command_ctest = 'ctest -I ' + ID + ',' + ID + ' -VV' + ' > ' + temp
		os.system(command_ctest)
		n += 1.0
		print n/NbTests*100.0
		ifstream = open(temp,'r')
		lines = ifstream.readlines()
		ifstream.close()
		
		flag = TestPb(lines)
		flags[flag].append(int(ID))

		
		ofstream.write(sep + "".join(lines) + sep)
	ofstream.close()
	
	print "------------------------------"
	print "NB of tests = " + str(len(testID))
	print "Success (" + str(len(flags[0])) + ") : ", flags[0]
	print "Baseline errors (" + str(len(flags[1])) + ") : ", flags[1]
	print "SegFault (" + str(len(flags[2])) + ") : ", flags[2]
	print "Linking errors (" + str(len(flags[3])) + ") : ", flags[3]
	print "Other errors (" + str(len(flags[4])) + ") : ", flags[4]
	print "Not found (" + str(len(flags[5])) + ") : ", flags[5]
	print "------------------------------"
	
	


# Process tests (by IDs)
def ProcessFile2(filename,destfile,tempfile):
	
	sep = '----------------------------- \n'
	
	flags=[[],[],[],[],[],[]]
	
	# reading file 
	ifstream = open(filename,'r')
	lines = ifstream.readlines()
	ifstream.close()	
	
		
	ofstream = open(destfile,'w')
	ofstream.close()

	
	testID=[]
	#for each line
	for l in lines:
		if ':' in l:
			sptl=l.split(":")
			testID.append(sptl[0])
		else:
			testID.append(l)
	
	testID = mapping(filename,tempfile)
	
	NbTests = float(len(testID))

	n = 0.0
	ofstream = open(destfile,'a')
	for ID in testID:	
		#command_ctest = 'ctest -I ' + ID + ',' + ID + ' -O ' + temp + ' -VV'
		command_ctest = 'ctest -I ' + ID + ',' + ID + ' -VV' + ' > ' + temp
		os.system(command_ctest)
		n += 1.0
		print n/NbTests*100.0
		ifstream = open(temp,'r')
		lines = ifstream.readlines()
		ifstream.close()
		
		flag = TestPb(lines)
		flags[flag].append(int(ID))

		
		ofstream.write(sep + "".join(lines) + sep)
	ofstream.close()
	
	print "------------------------------"
	print "NB of tests = " + str(len(testID))
	print "Success (" + str(len(flags[0])) + ") : ", flags[0]
	print "Baseline errors (" + str(len(flags[1])) + ") : ", flags[1]
	print "SegFault (" + str(len(flags[2])) + ") : ", flags[2]
	print "Libs errors (" + str(len(flags[3])) + ") : ", flags[3]
	print "Other errors (" + str(len(flags[4])) + ") : ", flags[4]
	print "Not found (" + str(len(flags[5])) + ") : ", flags[5]
	print "------------------------------"	
	



#------------------------- DOC -------------------------
# PURPOSE : Re-run tests that failed in very verbose mode (-VV), and concatenate the results into a single file (output-results).
# This script also provides a useful summary about the kind of errors that occured (screen output).
# 
# Tests that failed can usually be found in OTB-build/Testing/Temporary/LastTestsFailed.log
#
# USAGE : 1) Please, move this script into your OTB-build directory
# 2) Launch the following command : python ReRunFailedTests.py path-to-a-list-of-failed-tests output-results temp-file flag-same-platform
#
# It is important to tell the script whether re-run is done on the same platform (flag-same-platform).
# If not, the script will have to re-map the test names from platform A to the proper test IDs of platform B.
# Also note that even if re-run is done on the same platform, but from a different OTB-build directory, 'flag-same-platform' must be set to 0 (test IDs can be different).
#
# EXAMPLES :
# 1) Same platform : 
#  python ReRunFailedTests.py Testing/Temporary/LastTestsFailed_20150308-1800.log ReRunOutput.log /tmp/temp.log 1
# 2) Different platforms : 
#  python ReRunFailedTests.py LastTestsFailed-1st-platform.log ReRunOutput.log /tmp/temp.log 0
#------------------------- DOC -------------------------



# Main recursive loop
ctestLog = sys.argv[1]
dest = sys.argv[2]
temp = sys.argv[3]
flag = sys.argv[4]

if flag == '0': 
	print 'Different platforms'
	ProcessFile(ctestLog,dest,temp)
else:   
	print 'Same platform'
	ProcessFile2(ctestLog,dest,temp)
