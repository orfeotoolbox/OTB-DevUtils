import os, sys, shutil, datetime, subprocess

THIS_DIR = os.path.dirname(  os.path.abspath(__file__) )

# To identify the zipped sources
FFMPEG_SRC_VERSION="20121125-git-26c531c"
FFMPEG_SRC_DEV = os.path.join(THIS_DIR, "ffmpeg-%s-win32-dev.7z" % (FFMPEG_SRC_VERSION) )
FFMPEG_SRC_SHARED = os.path.join(THIS_DIR, "ffmpeg-%s-win32-shared.7z" % (FFMPEG_SRC_VERSION) )

# For the OSGeo4W package
FFMPEG_VERSION="20121125"
FFMPEG_PACKAGE_VERSION=1

EXE_TAR="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"
EXE_7Z="C:\\Program Files\\7-Zip\\7z.exe"

def make_package():	
	# init dest dir
	package_versioned_name = "ffmpeg-%s-%i" % (FFMPEG_VERSION, FFMPEG_PACKAGE_VERSION)
	dstdir = os.path.join(THIS_DIR, package_versioned_name)
	if os.path.exists(dstdir):
		shutil.rmtree(dstdir)
	os.mkdir(dstdir)

	# unzip input files
	unzipdir = os.path.join(THIS_DIR, "unzip-%s" % (FFMPEG_VERSION) )
	if os.path.exists(unzipdir):
		shutil.rmtree(unzipdir)
	os.mkdir(unzipdir)
	
	subprocess.call( [EXE_7Z, "x", "-o%s" % (unzipdir), FFMPEG_SRC_DEV] )
	subprocess.call( [EXE_7Z, "x", "-o%s" % (unzipdir), FFMPEG_SRC_SHARED] )
	
	unzipped_dev = os.path.join(unzipdir, "ffmpeg-%s-win32-dev" % (FFMPEG_SRC_VERSION))
	shutil.copytree( os.path.join(unzipped_dev, "include"), \
					 os.path.join(dstdir,"include") )
	shutil.copytree( os.path.join(unzipped_dev, "lib"), \
					 os.path.join(dstdir,"lib") )
	shutil.copytree( os.path.join(unzipped_dev, "doc"), \
					 os.path.join(dstdir, "share\\ffmpeg\\doc" ) )
	shutil.copytree( os.path.join(unzipped_dev, "licenses"), \
					 os.path.join(dstdir, "share\\ffmpeg\\licenses" ) )
	
	unzipped_shared = os.path.join(unzipdir, "ffmpeg-%s-win32-shared" % (FFMPEG_SRC_VERSION))
	shutil.copytree( os.path.join(unzipped_shared, "bin"), \
					 os.path.join(dstdir,"bin") )
	shutil.copytree( os.path.join(unzipped_shared, "presets"), \
					 os.path.join(dstdir, "share\\ffmpeg\\presets" ) )
	shutil.copy( os.path.join(unzipped_shared,"README.txt"), \
				 os.path.join(dstdir, "share\\ffmpeg" ) )
	
	# delete archive extraction
	shutil.rmtree( unzipped_dev )
	shutil.rmtree( unzipped_shared )
	
	# compress with osgeo4w compliance
	current_dir = os.getcwd()
	os.chdir( dstdir )
	subprocess.call( [EXE_TAR, "-cvjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
	os.chdir( current_dir )


if __name__ == "__main__" :
	make_package()
