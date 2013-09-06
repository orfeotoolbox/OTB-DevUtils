#!/usr/bin/python

import sys, os, commands, otbApplication
from optparse import OptionParser
import xml.etree.ElementTree as ET
import glob


def Execute(directory):
    path=directory + "/" + "IMG*PHR*_*" + "/" + "DIM_PHR*.XML"

    dimap_files = glob.glob(path)

    dimap_files.sort(reverse=True)

    if not dimap_files:
        raise Exception("No dimap found or unknown directory!")
    elif len(dimap_files) != 2:
        raise Exception("Work with 2 dimapv2 XML!")

    # Read images files (first image will be considered as the master)
    tabs= []

    for count in range(0,len(dimap_files)):
        dict = {'T_i': 0, 'T_e': 0,'nb_lig': 0,'nb_col': 0,'col_i': 0};
        
        print "parse Dimap file: ", dimap_files[count]
        tree = ET.parse(dimap_files[count])
        root = tree.getroot()
        
        print "dir",os.path.dirname(dimap_files[count])
        jp2_path=os.path.dirname(dimap_files[count]) +  "/" + "*.JP2"
        
        jp2_file=glob.glob(jp2_path)
        print jp2_file[0]

        time_range = root.find(".//Time_Range/START")
        T_i = time_range.text
        T_i = T_i[T_i.rfind(':')+1:-1]
    
        line_period=root.find(".//Time_Stamp/LINE_PERIOD")
        T_e=line_period.text
    
        nb_ligne=root.find(".//Raster_Dimensions/NROWS")
        NB_lig=nb_ligne.text

        nb_col=root.find(".//Raster_Dimensions/NCOLS")
        NB_col=nb_col.text

        col_i=root.find(".//Swath_Range/FIRST_COL")
        col_i=col_i.text
        
        dict['path'] = jp2_file[0]
        dict['T_i'] = float(T_i)
        dict['T_e']= float(T_e)
        dict['nb_lig'] = float(NB_lig)
        dict['nb_col'] = float(NB_col)
        dict['col_i'] = float(col_i)

        #Now get image size for in
        #path
        #print "directory", os.path.dirname(dimap_files[count])
        
        # img_path = os.path.dirname(dimap_files[count]) + "/" + "*.JP2"
        # img = glob.glob(img_path)
        # readinfo = otbApplication.Registry.CreateApplication("ReadImageInfo")
        # readinfo.SetParameterString("in",img[0])

        # readinfo.ExecuteAndWriteOutput()
        # #print readinfo.GetParametersKeys()
        # sizex = readinfo.GetParameterInt("sizex")
        # sizey = readinfo.GetParameterInt("sizey")

        # tab[count][5] = sizex
        # tab[count][6] = sizey

        tabs.append(dict)
        print "values for input dimap file ", dict

    dec_lig_MS_P_pixPAN =  int ((tabs[1]['T_i'] - tabs[0]['T_i'])/ (tabs[0]['T_e']/1000))
    dec_col_MS_P_pixPAN =  int(tabs[1]['col_i']*4 - tabs[0]['col_i']) 

    print "Le decalage en ligne (en pixels PAN) entre les 2 images est:", dec_lig_MS_P_pixPAN
    print "Le decalage en colonne (en pixels PAN) entre les 2 images est:", dec_col_MS_P_pixPAN

    # print "Ligne de commande pour re-echantilloner le XS: "
    # print 'otbcli_RigidTransformResample -in ... -transform.type translation -transform.type.translation.tx '+str(-1+dec_col_MS_P_pixPAN/4.+0.375)+' -transform.type.translation.ty '+str(dec_lig_MS_P_pixPAN/4.+0.375)+' -transform.type.translation.scalex 4 -transform.type.translation.scaley 4 -out xs_zoomed.tif?&gdal:co:TILED=yes&gdal:co:NBITS=12&box=0:0:'+str(tabs[0]['nb_col'])+':'+str(tabs[0]['nb_lig'])+' uint16'
    # print "\n"
    # print "Ligne de commande pour fusionner les images: "
    # print "otbcli_Pansharpening -inp ... -inxs xs.tif -out ... uint16"

    print "pan path", tabs[0]['path']
    print "xs path", tabs[1]['path']
    
    zoom_app="/home/grizonnetm/projets/otb/bin/release/OTB/bin/otbApplicationLauncherCommandLine RigidTransformResample /home/grizonnetm/projets/otb/bin/release/OTB/bin/"
    #zoom_app="otbcli_RigidTransformResample"

    zoom_cmd = zoom_app + " -in " + str(tabs[1]['path']) + " -transform.type translation -transform.type.translation.tx "+str(-1+dec_col_MS_P_pixPAN/4.+0.375)+" -transform.type.translation.ty "+str(dec_lig_MS_P_pixPAN/4.+0.375)+" -transform.type.translation.scalex 4 -transform.type.translation.scaley 4 -out \"xs_zoomed.tif?&gdal:co:TILED=yes&gdal:co:NBITS=12&box=0:0:"+str(tabs[0]['nb_col'])+":"+str(tabs[0]['nb_lig'])+"\"" + " uint16 -ram 512"

    print zoom_cmd
    status,output = commands.getstatusoutput(zoom_cmd)

    if not status == 0:
        print "Error"
        print "Command: "+zoom_cmd
        
        print output

    fusion_cmd = "otbcli_Pansharpening " + "-inp " + tabs[0]['path'] + " -inxs " + " xs_zoomed.tif -out \"fusion.tif?&gdal:co:TILED=yes&gdal:co:NBITS=12\" uint16 -ram 512"
    
    print fusion_cmd
    status,output = commands.getstatusoutput(fusion_cmd)

    if not status == 0:
        print "Error"
        print "Command: "+fusion_cmd
        
        print output

def main():
    parser = OptionParser(usage="usage: %prog [options] filename",
                          version="%prog 1.0")

    parser.add_option("-d","--directory", help="absolute path to bundle product directory", dest="path", type="string")
    #parser.add_option("-r","--ram", help="ram value", dest="ram", type="int")

    (opts, args) = parser.parse_args()

    if opts.path is None:
        print "A mandatory option is missing\n"
        parser.print_help()
        exit(-1)
    else:
        #print opts.path
        Execute(opts.path)

if __name__ == '__main__':
    main()
   
