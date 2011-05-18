# The input is a csv file produces by Mantis
# Output on stdout the bug desciption to put on the release note

import csv, sys

def main():

  filename = sys.argv[1]
  csv_reader = csv.DictReader(open(filename, 'r'))
  csv_reader.next()
  
  result = {}
  
  for row in csv_reader:
      bugdesc = '    * '+row['Id']+': '+row['Summary']+'\n'
      if row['Project'] not in result:
          result[row['Project']] = ''
      result[row['Project']] = result[row['Project']]+bugdesc
  
  for d in result:
      print '  * '+d
      print result[d]
      
if __name__ == '__main__':
  main()
