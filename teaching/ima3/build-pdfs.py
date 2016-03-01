#!/usr/bin/env python
# -*-coding:utf-8 -*
"""
Generate output for markdown needed for website file links.
"""
from os import listdir
from os.path import isfile, join

onlyfiles = [f for f in listdir(".") if isfile(join(".", f))]

print (onlyfiles)


#def cleanup(templates=template_files):
    #for tmplt in templates:
        #print ("Cleaning up temp files for "+tmplt+ "...")
        #subprocess.call("rm " + tmplt + ".log", shell=True)
        #subprocess.call("rm " + tmplt + ".aux", shell=True)

#def getFileName(pdf_name):
    #file_name = (os.path.splitext(os.path.basename(pdf_name))[0])
    ##print ("Filename: " + file_name)
    #return file_name
    ##print (os.path.basename(pdf_name))
    ##print (os.path.splitext(pdf_name)[1])

#def renamePDF(source, dest, ending):
    #cmd = "mv " + source+".pdf "  +   dest+"-"+ending   + ".pdf"
    #print ("       Moving file: "+cmd)
    #subprocess.call(cmd , shell=True)

#"""
#MAIN
#"""

##compile_pdfs(templates[0],pdf_files)
#compile_pdfs()
##print ("")
#cleanup()

##print ("The end...")
