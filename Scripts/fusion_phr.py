#!/usr/bin/python

import sys, os, commands, otbApplication
from optparse import OptionParser
import xml.etree.ElementTree as ET
import glob

###########################################################################################################################
# Les infos importantes a aller lire dans les XML sont:

#       <Time>

#         <Time_Range>

#           <START>2012-04-01T10:17:34.3190000Z</START>                                => T_i_MS / T_i_P

#           <END>2012-04-01T10:17:36.9860000Z</END>                                                        => T_f_MS / T_f_P

#         </Time_Range>

#         <Time_Stamp>

#          <LINE_PERIOD>0.2968</LINE_PERIOD>                                                                   => Te_MS / Te_P (normalement Te_P = 4 x Te_MS)

#         </Time_Stamp>

#       </Time>

# et  :

#     <Raster_Dimensions>

#       <NROWS>8986</NROWS>                                                                                                 => NB_lig_MS / NB_lig_P

#       <NCOLS>10375</NCOLS>                                                                                                   => NB_col_MS / NB_col_P

#       <NBANDS>4</NBANDS>

# et :

#           <Swath_Range>

#             <FIRST_COL>1</FIRST_COL>                                                                                      => col_i_MS / col_i_P

#             <LAST_COL>10375</LAST_COL>                                                                                => col_f_MS / col_f_P

#           </Swath_Range>


# Le decalage en ligne (en pixels PAN) entre les 2 images est:

# dec_lig_MS_P_pixPAN =  int ((T_i_MS - T_i_PA)/ (Te_P/1000))              car le Te est donne en ms.

# Le decalage en colonne (en pixel PAN) entre les 2 images est:

# dec_col_MS_P_pixPAN = int((col_i_MS*4 - col_i_P))

# Il faut donc supprimer ces lignes et colonnes en trop en haut et a gauche de l'image puis en extraire ncol / nlig (sur l'image XS) et 4 x ncol / 4 x nlig (sur l'image PA)

# Les extraits ainsi elabores sont alors superposables au zoom 4 pres.

# => en revanche, les RPC ne sont plus bons si tu as decoupe les images.
#########################################################################################################


def Execute(directory,ram,dem,geoid):

    path=os.path.join(os.path.join(directory,"IMG*PHR*_*"),"DIM_PHR*.XML")

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
        jp2_path=os.path.join(os.path.dirname(dimap_files[count]),"*.JP2")
        
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
        dict['nb_lig'] = int(NB_lig)
        dict['nb_col'] = int(NB_col)
        dict['col_i'] = float(col_i)

        tabs.append(dict)
        print "values for input dimap file ", dict

    dec_lig_MS_P_pixPAN =  int ((tabs[1]['T_i'] - tabs[0]['T_i'])/ (tabs[0]['T_e']/1000))
    dec_col_MS_P_pixPAN =  int(tabs[1]['col_i']*4 - tabs[0]['col_i']) 

    print "Le decalage en ligne (en pixels PAN) entre les 2 images est:", dec_lig_MS_P_pixPAN
    print "Le decalage en colonne (en pixels PAN) entre les 2 images est:", dec_col_MS_P_pixPAN

    print "pan path", tabs[0]['path']
    print "xs path", tabs[1]['path']

    xs_without_extension=os.path.splitext(os.path.basename(tabs[1]['path']))[0]
    xs_zoom_path = os.path.join(directory,xs_without_extension) + "_zoom.tif"
    
    print "xs_zoom_path" , xs_zoom_path 
    
    #FIXME local path to dev version of this otb app
    zoom_app="/home/grizonnetm/projets/otb/bin/release/OTB/bin/otbApplicationLauncherCommandLine RigidTransformResample /home/grizonnetm/projets/otb/bin/release/OTB/bin/"
    #zoom_app="otbcli_RigidTransformResample"

    zoom_cmd = zoom_app + " -in " + str(tabs[1]['path']) + " -transform.type translation -transform.type.translation.tx "+str(-1+dec_col_MS_P_pixPAN/4.+0.375)+" -transform.type.translation.ty "+str(dec_lig_MS_P_pixPAN/4.+0.375)+" -transform.type.translation.scalex 4 -transform.type.translation.scaley 4 -out \"" + xs_zoom_path + "?&gdal:co:TILED=yes&gdal:co:NBITS=12&box=0:0:"+str(tabs[0]['nb_col'])+":"+str(tabs[0]['nb_lig'])+"\"" + " uint16 -ram " + ram

    print zoom_cmd
    status,output = commands.getstatusoutput(zoom_cmd)

    if not status == 0:
        print "Error"
        print "Command: "+zoom_cmd
        
        print output

    
    fusion_path = os.path.join(directory,os.path.basename(directory)) + "_pxs.tif" 
    print "fusion_path" , fusion_path 

    fusion_cmd = "otbcli_Pansharpening " + "-inp " + tabs[0]['path'] + " -inxs " + xs_zoom_path + " -out \"" + fusion_path + "?&gdal:co:TILED=yes&gdal:co:NBITS=12\" uint16 -ram " + ram
    
    print fusion_cmd
    status,output = commands.getstatusoutput(fusion_cmd)

    if not status == 0:
        print "Error"
        print "Command: "+fusion_cmd
        
        print output


    ortho_path = os.path.join(directory,os.path.basename(directory)) + "_ortho_pxs.tif"
    
    #orthorectification
    dem_option= " -elev.dem " + dem 
    geoid_option= " -elev.geoid " + geoid
    ortho_cmd = "otbcli_OrthoRectification -io.in " + fusion_path + " -io.out \"" + ortho_path + "?&gdal:co:TILED=yes&gdal:co:NBITS=12\" uint16 -outputs.mode auto -outputs.spacingx 0.5 -outputs.spacingy -0.5" + dem_path + geoid_path + " -opt.ram " + ram

    print "ortho_cmd", ortho_cmd
    status,output = commands.getstatusoutput(fusion_cmd)

    if not status == 0:
        print "Error"
        print "Command: "+ortho_cmd
        
        print output

def main():
    parser = OptionParser(usage="usage: %prog [options] filename",
                          version="%prog 1.0")

    parser.add_option("-p","--path_bundle", help="absolute path to bundle product directory", dest="img_path", type="string")
    parser.add_option("-r","--ram", help="ram value", dest="ram", type="string", default=512)
    parser.add_option("-d","--dem", help="dem directory", dest="dem", type="string")
    parser.add_option("-g","--geoid", help="geoid file", dest="geoid", type="string")

    (opts, args) = parser.parse_args()

    if opts.img_path is None or opts.dem is None or opts.geoid is None: 
        print "A mandatory option is missing\n"
        parser.print_help()
        exit(-1)
    else:
        #print opts.path
        Execute(os.path.dirname(opts.img_path),opts.ram,os.path.dirname(opts.dem),opts.geoid)

if __name__ == '__main__':
    main()
   
