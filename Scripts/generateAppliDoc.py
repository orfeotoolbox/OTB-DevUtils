# -*- coding: utf-8 -*-

import sys, string, shutil, os

def help():
  print """
  This script provides an easy way to generate the application documentation in html format.
  It uses the class otbWrapperApplicationHtmlDocGenerator class to do so.
  Waits as input the OTB_Binary path and the output directory where the doc will be generated.
  """

def main(argv):
  argc = len(argv)
  if (argc < 2):
    help()
    return

  otbbin = argv[1]
  outDir = argv[2] + "/" 
  docExe = otbbin + "/bin/otbWrapperTests otbWrapperApplicationHtmlDocGeneratorTest1 "
  cmakeFile = otbbin + "/CMakeCache.txt"
  
  appliKey = "OTB_APPLICATIONS_NAME_LIST"
  
  f = open(cmakeFile, 'r')
  fout = open(outDir+"main.html", 'w')
  fout.write("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//ENhttp://www.w3.org/TR/REC-html40/strict.dtd\"><html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">p, li { white-space: pre-wrap; }</style></head><body style=\" font-family:'Sans Serif'; font-size:9pt; font-weight:400; font-style:normal;\"></style></head><body style=\" font-family:'Sans Serif'; font-size:9pt; font-weight:400; font-style:normal;\">")
  fout.write("<h1>Aplication main documentation</h1>")
  fout.write("Available applications:<br /><br />")
  for line in f:
    if line.find(appliKey) != -1 :
      # supress white space if any
      line2 = line.strip()
      # supress line return
      line = line.strip(" \n")
      print line
      appList = line.split("=")[1]
      for app in appList.split(";") :
        if app != "TestApplication" :
          print ("Generating " + app + " ...")
          filename = outDir + app + ".html"
          commandLine = docExe + " " + app + " " + otbbin + "/bin " + filename;
          os.system(commandLine)

          outLine = "<a href=\"" + filename + "\">" + app + "</a><br />"
          fout.write(outLine)
      break
    
  f.close()

  fout.write("</body")
  fout.write("</html>") 
  fout.close()

if __name__ == "__main__":
    main(sys.argv)
