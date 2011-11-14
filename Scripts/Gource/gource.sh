############################################################
# usage:  gource.sh otb_projects_source_dir gource_output_dir
############################################################
#!/bin/bash 

#Combination and remove style commit (>=50)
#Work with custom logs
#http://code.google.com/p/gource/wiki/CustomLogFormat
#Mercurial template -> csv
#python processing -> log file
#convert hgdate into unix date, format names, one line per file, +color per type?


otb_src_dir=~/projets/otb/src
gource_dir=~/projets/otb/gource
repo_otb=( "OTB" "OTB-Applications" "Monteverdi" "OTB-Documents" "OTB-Qgis-plugins" "OTB-Wrapping")

cd $otb_src_dir

for i in "${repo_otb[@]}"
do
   cd $otb_src_dir/$i
   hg pull --rebase 
   hg up
   echo "generate log..." 
   hg log --template '{date|hgdate}, {author|person}, {files},{files_adds}, {file_dels}\n' > $gource_dir/output-$i.csv
   #work in ~/prog/gource
   cd $gource_dir
   echo "process gource log..."
   python processLogs.py $i
   #(input output.csv, output output.log)
done

cd $gource_dir

#+combine +sort
sort output-Monteverdi.log output-OTB-Applications.log output-OTB-Documents.log output-OTB.log output-OTB-Qgis-plugins.log output-OTB-Wrapping.log > output-full.log

#remove Utilities
grep -v '/Utilities/' output-full.log > output-full-noutils.log

gource -640x480 -s 0.1 --hide filenames --highlight-users --date-format '%Y-%m-%d' --stop-at-end --output-ppm-stream --log-format hg -o - output-full-noutils.log | ffmpeg -y -b 3000K -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -vpre default otb_gource_full.mp4

exit 0
