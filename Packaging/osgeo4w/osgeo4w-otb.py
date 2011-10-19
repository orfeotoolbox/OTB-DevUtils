import os, sys, shutil, datetime, subprocess


OTB_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\OTB-Release-VC2008"
OSGEO4W_STAGING="C:\\Users\\jmalik\\Dashboard\\osgeo4w"
OSGEO4W_TEMPLATE="C:\\Users\\jmalik\\Dashboard\\src\\OTB-DevUtils\\Packaging\\osgeo4w"

# TODO extract this automatically
OTB_VERSION="3.11.0"

#COMPRESS7Z="C:\\Program Files\\7-Zip\\7z.exe"
TAREXE="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"

todayiso = datetime.date.today().isoformat().replace('-','')
yesterdayiso = (datetime.date.today()-datetime.timedelta(1)).isoformat().replace('-','')

def initialize_package(packagebasename, src_version, pkg_version, stage_root):
    # directory where installation files will be staged
    package_versioned_name = packagebasename + "-" + OTB_VERSION + "-" + yesterdayiso + "-1"
    dstdir = os.path.join(OSGEO4W_STAGING, package_versioned_name)

    # copy the template to the dstdir
    if os.path.exists(dstdir):
        shutil.rmtree(dstdir)
    shutil.copytree( os.path.join(OSGEO4W_TEMPLATE, "template-" + packagebasename), dstdir )
    
    remove_placeholder_files(dstdir)

    return package_versioned_name

def remove_placeholder_files(dirname):
    for root, dirs, files in os.walk(dirname, topdown=False):
        for name in files:
          if name == "placeholder":
            os.remove(os.path.join(root, name))

def make_tarbz2(package_versioned_name):
    os.chdir(OSGEO4W_STAGING)
    subprocess.call( [TAREXE, "-cvjf", package_versioned_name + ".tar.bz2",  package_versioned_name + "/*" ] )

def make_otb_bin():
    package_name = "otb-bin"
    package_versioned_name = initialize_package(package_name, OTB_VERSION, yesterdayiso, OSGEO4W_STAGING)

    # copy the content of lib/otb/applications to apps/orfeotoolbox/applications
    inputdir = os.path.join(OTB_INSTALL, "lib\\otb\\applications")
    for fic in os.listdir( inputdir ) :
      shutil.copy( os.path.join(inputdir, fic), \
                   os.path.join(os.path.join(OSGEO4W_STAGING, package_versioned_name), "apps", "orfeotoolbox", "applications" ) )
    make_tarbz2(package_versioned_name)
                   
def make_otb_python():
    package_name = "otb-python"
    package_versioned_name = initialize_package(package_name, OTB_VERSION, yesterdayiso, OSGEO4W_STAGING)
    
    # copy the content of lib/otb/python to apps/orfeotoolbox/python
    inputdir = os.path.join(OTB_INSTALL, "lib\\otb\\python")
    for fic in os.listdir( inputdir ) :
      shutil.copy( os.path.join(inputdir, fic), \
                   os.path.join(os.path.join(OSGEO4W_STAGING, package_versioned_name), "apps", "orfeotoolbox", "python" ) )
    make_tarbz2(package_versioned_name)

make_otb_bin()
make_otb_python()