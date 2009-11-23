#!/usr/bin/python
#coding=utf8
import fileinput,glob,string,sys,os,stat
from os.path import join

####### PARAMETERS #################
versionTranslationTable = {
'version 1.0110' : 'version 1.0107'
}
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
	

# Test if the file is a fluid file
def IsFluidFile(filename):
	return filename.endswith('.fl')

# Process the fuild file
def ProcessFluidFile(filename):
	# reading file
	ifstream = open(filename,'r')
	lines = ifstream.readlines()
	ifstream.close()
	
	newfile = []
	# Wether we need to remove the 'value 1' field or not
	shouldRemoveValue = False
	#for each line in file
	for line in lines:
		# replace the version
		newline = line.replace('version 1.0110',versionTranslationTable['version 1.0110'])
		if(shouldRemoveValue):
			newline = newline.replace('value 1','')
		newfile.append(newline)
		ofstream = open(filename,'w')
		ofstream.write("".join(newfile))
		ofstream.close()
		# if the line contains 'Fl_"
		if (line.find('Fl_') != -1):
			# if it is a Spinner
			if(line.find('Fl_Spinner') != -1):
				# we will have to remove the 'value 1' field in the following lines
				shouldRemoveValue = True
			else:
				# else we should avoid removing the field in the following lines
				shouldRemoveValue = False
		
	
	return

# Main recursive loop
for (dir,files) in RecursiveDirectoriesListing():
	for file in files:
		if IsFluidFile(file):
			path = join(dir,file)
			print 'Processing fluid file: '+path
			ProcessFluidFile(path)
	
	

