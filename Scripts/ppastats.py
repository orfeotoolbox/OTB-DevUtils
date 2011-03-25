#!/usr/bin/python

from launchpadlib.launchpad import Launchpad
PPAOWNER = "otb" #the launchpad PPA owener. It's usually the first part of a PPA. Example: in "webupd8team/vlmc", the owener is "webupd8team".
PPA = "orfeotoolbox-stable-ubuntugis" #the PPA to get stats for. It's the second part of a PPA. Example: in "webupd8team/vlmc", the PPA is "vlmc"
desired_dist_and_arch = 'https://api.edge.launchpad.net/devel/ubuntu/maverick/i386' #here, edit "maverick" and "i386" with the Ubuntu version and desired arhitecture

for ppa in ['orfeotoolbox-stable', 'orfeotoolbox-stable-ubuntugis', 'orfeotoolbox-nightly' ]:
  for distrib in ['lucid', 'maverick']:
    for arch in ['i386','amd64']:
     desired_dist_and_arch = 'https://api.edge.launchpad.net/devel/ubuntu/' + distrib + '/' + arch
     print '-----------------------------------------'
     print ppa + ' ' + distrib + " - " + arch
     cachedir = "~/.launchpadlib/cache/"
     lp_ = Launchpad.login_anonymously('ppastats', 'edge', cachedir, version='devel')
     owner = lp_.people[PPAOWNER]
     archive = owner.getPPAByName(name=ppa)

     for individualarchive in archive.getPublishedBinaries(status='Published',distro_arch_series=desired_dist_and_arch):
       print individualarchive.binary_package_name + "\t" + individualarchive.binary_package_version + "\t" + str(individualarchive.getDownloadCount())
