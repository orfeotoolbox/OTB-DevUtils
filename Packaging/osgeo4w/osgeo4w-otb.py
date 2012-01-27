import os, sys, shutil, datetime, subprocess


OTB_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\OTB-Release-VC2008-ExternalOssim"
MONTEVERDI_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\Monteverdi-Release-VC2008"
OSSIM_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\ossim-trunk"
OSGEO4W_STAGING="C:\\Users\\jmalik\\Dashboard\\osgeo4w"
OSGEO4W_TEMPLATE="C:\\Users\\jmalik\\Dashboard\\src\\OTB-DevUtils\\Packaging\\osgeo4w"
TAREXE="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"

# TODO extract this automatically
OTB_VERSION="3.11.0"
MONTEVERDI_VERSION="1.9.0"


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

    # copy the .bat launcher in bin
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
    # we need an ossim package !!!
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbossimplugins.dll"),
                 os.path.join(OSGEO4W_STAGING, package_versioned_name, "bin" ) )
    shutil.copy( os.path.join(OSSIM_INSTALL, "bin", "ossim.dll"),
                 os.path.join(OSGEO4W_STAGING, package_versioned_name, "bin" ) )
    
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

make_otb_bin()
make_otb_python()
make_monteverdi()