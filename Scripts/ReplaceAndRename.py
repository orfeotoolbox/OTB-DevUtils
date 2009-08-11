#!/usr/bin/python
#coding=utf8
import fileinput,glob,string,sys,os,stat,shutil
from os.path import join

####### FUNCTIONS ###################
def RecursiveDirectoriesListing(top="."):
	""" List directories recursively"""
	names = os.listdir(top)
	for name in names:
		try:
			st = os.lstat(join(top,name))
		except os.error:
			continue
		if stat.S_ISDIR(st.st_mode):
			for(newtop,children) in RecursiveDirectoriesListing(join(top,name)):
				yield newtop,children
	yield top,names
	

# Process the fuild file
def ProcessFile(filename,srcKey,destKey):
	# reading file
	ifstream = open(filename,'r')
	lines = ifstream.readlines()
	ifstream.close()	
	newfile = []
	#for each line in file
	repCount = 0
	for line in lines:
		# replace the version
		repCount=repCount + line.count(srcKey)
		newline = line.replace(srcKey,destKey)
		newfile.append(newline)
	ofstream = open(filename,'w')
	ofstream.write("".join(newfile))
	ofstream.close()
	return repCount

# Main recursive loop
path = sys.argv[1]
sKey = sys.argv[2]
dKey = sys.argv[3]

for (dir,files) in RecursiveDirectoriesListing(path):
	for file in files:
		src = join(dir,file)
		# First process file content
		nbReplaces=ProcessFile(src,sKey,dKey)
		print "File "+src+" Processed, ", nbReplaces, " occurences replaced."
		# Then, eventually rename
		if src.count(sKey):
			dest = src.replace(sKey,dKey)
			shutil.move(src,dest)
			print 'Renaming file: '+src+' to '+dest 
			
	
	

