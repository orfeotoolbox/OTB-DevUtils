import os, sys, shutil, datetime, subprocess

OTB_SRC="C:\\Users\\jmalik\\Dashboard\\src\\OTB"
MONTEVERDI_SRC="C:\\Users\\jmalik\\Dashboard\\src\\Monteverdi"
OTB_WRAPPING_SRC="C:\\Users\\jmalik\\Dashboard\\src\\OTB-Wrapping"

OTB_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\OTB-RelWithDebInfo-VC2010"
MONTEVERDI_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\Monteverdi-RelWithDebInfo-VC2010"
#OTB_WRAPPING_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\OTB-Wrapping-RelWithDebInfo-VC2008"

OSGEO4W_STAGING="C:\\Users\\jmalik\\Dashboard\\osgeo4w"
OSGEO4W_TEMPLATE="C:\\Users\\jmalik\\Dashboard\\src\\OTB-DevUtils\\Packaging\\osgeo4w"
TAREXE="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"

def get_version(cmakelistpath, id):
    with open(cmakelistpath) as cmakelist:
        for line in cmakelist:
            if "SET(" + id + "_VERSION_MAJOR" in line:
                MAJOR = line.split()[1].split('"')[1]
                
            if "SET(" + id + "_VERSION_MINOR" in line:
                MINOR = line.split()[1].split('"')[1]
                
            if "SET(" + id + "_VERSION_PATCH" in line:
                PATCH = line.split()[1].split('"')[1]
    return "%s.%s.%s" % (MAJOR, MINOR, PATCH)

OTB_VERSION = get_version( os.path.join(OTB_SRC, "CMakeLists.txt"), "OTB" )
print "OTB version : %s" % OTB_VERSION

MONTEVERDI_VERSION = get_version( os.path.join(MONTEVERDI_SRC, "CMakeLists.txt"), "Monteverdi" )
print "Monteverdi version : %s" % MONTEVERDI_VERSION

#OTB_WRAPPING_VERSION = get_version( os.path.join(OTB_WRAPPING_SRC, "CMakeLists.txt"), "OTB-Wrapping" )
#print "OTB-Wrapping version : %s" % OTB_WRAPPING_VERSION


todayiso = datetime.date.today().isoformat().replace('-','')
yesterdayiso = (datetime.date.today()-datetime.timedelta(1)).isoformat().replace('-','')

def initialize_package(packagebasename, src_version, pkg_version, stage_root):
    # directory where installation files will be staged
    package_versioned_name = packagebasename + "-" + src_version + "-" + yesterdayiso + "-1"
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
    current_dir = os.getcwd()
    os.chdir( os.path.join(OSGEO4W_STAGING, package_versioned_name) )
    subprocess.call( [TAREXE, "-cvjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
    os.chdir( current_dir )

def make_otb_bin():
    package_name = "otb-bin"
    package_versioned_name = initialize_package(package_name, OTB_VERSION, yesterdayiso, OSGEO4W_STAGING)

    # copy the content of lib/otb/applications to apps/orfeotoolbox/applications
    inputdir = os.path.join(OTB_INSTALL, "lib\\otb\\applications")
    for fic in os.listdir( inputdir ) :
      shutil.copy( os.path.join(inputdir, fic), \
                   os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "applications" ) )

    # copy the .bat launchers in bin
    inputdir = os.path.join(OTB_INSTALL, "bin")
    outputbindir = os.path.join(OSGEO4W_STAGING, package_versioned_name, "bin" )
    for fic in os.listdir( inputdir ) :
      if fic.startswith("otbcli") or fic.startswith("otbgui"):
        shutil.copy( os.path.join(inputdir, fic), \
                     outputbindir )

    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbApplicationLauncherCommandLine.exe"), outputbindir )
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbApplicationLauncherQt.exe"), outputbindir )
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbViewer.exe"), outputbindir )
    
    # copy ossim and ossimplugin dll in the otbbin package for now
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbossimplugins.dll"), outputbindir )
    
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
    
def make_monteverdi():
    package_name = "otb-monteverdi"
    package_versioned_name = initialize_package(package_name, MONTEVERDI_VERSION, yesterdayiso, OSGEO4W_STAGING)

    # copy the content of lib/otb/applications to apps/orfeotoolbox/applications
    inputdir = os.path.join(MONTEVERDI_INSTALL, "bin")
    shutil.copy( os.path.join(MONTEVERDI_INSTALL, "bin", "monteverdi.exe"),
                 os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "monteverdi", "bin" ) )
   
    make_tarbz2(package_versioned_name)

def make_otb_wrapping():
    package_name = "otb-wrapping"
    package_versioned_name = initialize_package(package_name, OTB_WRAPPING_VERSION, yesterdayiso, OSGEO4W_STAGING)
    
    inputdir = os.path.join(OTB_WRAPPING_INSTALL, "lib", "otb-wrapping")
    outputdir = os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "wrapping")
    if os.path.exists(outputdir):
        shutil.rmtree(outputdir) # or copytree fails...
    shutil.copytree( inputdir, outputdir )
    make_tarbz2(package_versioned_name)

make_otb_bin()
make_otb_python()
make_monteverdi()

# Not supported on VC2010
#make_otb_wrapping()
