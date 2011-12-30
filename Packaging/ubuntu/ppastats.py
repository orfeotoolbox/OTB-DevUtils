#!/usr/bin/python
# Prints download stats from Launchpad PPA.

from launchpadlib.launchpad import Launchpad

PPAOWNER = "otb"  # PPA owner
PPA = "orfeotoolbox-stable" # PPA name

cachedir = "~/.cache/launchpadlib/"
apiurl = 'https://api.edge.launchpad.net/devel/ubuntu/'

lp_ = Launchpad.login_anonymously('ppastats', 'edge', cachedir, version='devel')
owner = lp_.people[PPAOWNER]
archive = owner.getPPAByName(name=PPA)

summary = {}

def printDLCount(ppaname, distarch):
        print '------ ' + ppaname + '  ' + distarch + ' --------'
        archive = owner.getPPAByName(name=ppaname)
        for i in archive.getPublishedBinaries(status='Published',distro_arch_series=apiurl+distarch):
                # Uncomment last part of next line to get daily stats        
                print i.binary_package_name + "\t" + i.binary_package_version + "\t" + str(i.getDownloadCount()) #+ "\t" + str(i.getDailyDownloadTotals())i
                if not i.binary_package_name in summary.keys():
                  summary[ i.binary_package_name ] = 0
                summary[ i.binary_package_name ] = summary[ i.binary_package_name ] + i.getDownloadCount()

print "Package\tVersion\tDownloads" #"\tDaily DLs"
print

printDLCount("orfeotoolbox-stable", "oneiric/i386")
printDLCount("orfeotoolbox-stable", "oneiric/amd64")
printDLCount("orfeotoolbox-stable", "natty/i386")
printDLCount("orfeotoolbox-stable", "natty/amd64")
printDLCount("orfeotoolbox-stable", "maverick/i386")
printDLCount("orfeotoolbox-stable", "maverick/amd64")
printDLCount("orfeotoolbox-stable", "lucid/i386")
printDLCount("orfeotoolbox-stable", "lucid/amd64")
printDLCount("orfeotoolbox-stable", "karmic/i386")
printDLCount("orfeotoolbox-stable", "karmic/amd64")
printDLCount("orfeotoolbox-stable", "karmic/lpia")


printDLCount("orfeotoolbox-stable-ubuntugis", "oneiric/i386")
printDLCount("orfeotoolbox-stable-ubuntugis", "oneiric/amd64")
printDLCount("orfeotoolbox-stable-ubuntugis", "natty/i386")
printDLCount("orfeotoolbox-stable-ubuntugis", "natty/amd64")
printDLCount("orfeotoolbox-stable-ubuntugis", "maverick/i386")
printDLCount("orfeotoolbox-stable-ubuntugis", "maverick/amd64")
printDLCount("orfeotoolbox-stable-ubuntugis", "lucid/i386")
printDLCount("orfeotoolbox-stable-ubuntugis", "lucid/amd64")
printDLCount("orfeotoolbox-stable-ubuntugis", "karmic/i386")
printDLCount("orfeotoolbox-stable-ubuntugis", "karmic/amd64")
printDLCount("orfeotoolbox-stable-ubuntugis", "karmic/lpia")

print
print
print '------ Summary --------'

for name in summary.keys():
  print name + ' : ' +  str(summary[ name ])

