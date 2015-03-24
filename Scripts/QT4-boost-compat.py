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
	
		
def Test(line,tag):
	
	QTHeaders = ['QtGui','QString','QObject','QPixmap','QSplashScreen','QtOpenGL','QtCore','QtSql','QtXml'] #To be completed
	boolQTHeaders=True
	for qthead in QTHeaders :
			if qthead in line:
				boolQTHeaders=False
	
	if '#' in line and 'include' in line and '//' not in line[0:2] and line != '\n' and tag not in line and boolQTHeaders :
		return True
	else:
		return False

# Process the fuild file
def ProcessFile(filename):
	
	if '.cmake' in filename or 'TestDriver' in filename or not (filename[-2]=='.' and filename[-1]=='h'):
		return 0

	tag='QT4-boost-compatibility'
	
	destKey1 = '#ifndef Q_MOC_RUN  // See: https://bugreports.qt-project.org/browse/QTBUG-22829  //tag=' + tag
	destKey2 = '#endif //tag=' + tag 

	# reading file
	ifstream = open(filename,'r')
	lines = ifstream.readlines()
	ifstream.close()	

	#for each line in file
	newfile = []
	repCountBegin = 0
	repCountEnd = 0
	L = len(lines)
	for i in range(L):
		
		if i==0 and Test(lines[0],tag)==True: # special case
			newline = destKey1 + '\n' + lines[0]
			repCountBegin += 1
		else:
			newline = lines[i]

		if i+1<L:
			if Test(lines[i],tag)==False and Test(lines[i+1],tag)==True:
				newline += destKey1 + '\n'
				repCountBegin += 1
			if Test(lines[i],tag)==True and Test(lines[i+1],tag)==False:
				newline += destKey2 + '\n'
				repCountEnd += 1
		newfile.append(newline)

	ofstream = open(filename,'w')
	ofstream.write("".join(newfile))
	ofstream.close()
	return repCountBegin-repCountEnd

# Main recursive loop
path = sys.argv[1]

for (dir,files) in RecursiveDirectoriesListing(path):
	if ".hg" not in dir and ".git" not in dir and ".orig" not in dir:
		for file in files:
			src = join(dir,file)
			# First process file content
			nbReplaces=ProcessFile(src)
			if nbReplaces != 0:
				print "File "+src+" Processed, ", nbReplaces

