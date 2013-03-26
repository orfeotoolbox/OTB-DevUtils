#!/bin/sh
# OTB specific script to extract exported libopenjpeg symbols that can be renamed
# to keep them internal to OTB as much as possible (based on what it does by GDAL
# for internal libtiff)

OPJ_SRC_PATH=/path/to/OTB/Utilities/otbopenjpeg
OPJ_BUILD_PATH=/path/where/build/otbopenjpeg
OUT_FILE=/path/where/create/openjpeg_mangle.h.cmake.in

rm $OPJ_BUILD_PATH
mkdir $OPJ_BUILD_PATH
cd $OPJ_BUILD_PATH
cmake $OPJ_SRC_PATH -DCMAKE_BUILD_TYPE:STRING=Debug # In debug more symbols appear
make


rm $OUT_FILE 2>/dev/null

echo "/* This is a generated file by openjpeg_dump_symbols.sh *DO NOT EDIT MANUALLY !* */" >> $OUT_FILE

echo "#ifndef openjpeg_mangle_h" >> $OUT_FILE
echo "#define openjpeg_mangle_h\n" >> $OUT_FILE
echo "#cmakedefine OPJ_USE_MANGLE_PREFIX\n" >> $OUT_FILE
echo "#ifdef OPJ_USE_MANGLE_PREFIX\n" >> $OUT_FILE

# grep functions
symbol_list=$(objdump -t bin/libopenjpeg.so  | grep .text | awk '{print $6}' | grep -v .text | grep -v __do_global | grep -v call_gmon_start | grep -v frame_dummy| sort)
for symbol in $symbol_list
do
    #echo "#define $symbol @OPJ_MANGLE_PREFIX@_$symbol" >> $OUT_FILE
    echo $symbol | sed 's/.*/#define & @OPJ_MANGLE_PREFIX@_&/' | awk '{printf "%-8s%-40s%s\n", $1, $2, $3}'  >> $OUT_FILE
done


rodata_symbol_list=$(objdump -t bin/libopenjpeg.so  | grep "\.rodata" |  awk '{print $6}' | grep -v "\.")
for symbol in $rodata_symbol_list
do
    #echo "#define $symbol @OPJ_MANGLE_PREFIX@_$symbol" >> $OUT_FILE
    echo $symbol | sed 's/.*/#define & @OPJ_MANGLE_PREFIX@_&/' | awk '{printf "%-8s%-40s%s\n", $1, $2, $3}'  >> $OUT_FILE
done

data_symbol_list=$(objdump -t bin/libopenjpeg.so  | grep "\.data" | grep -v __dso_handle | awk '{print $6}' | grep -v "\.")
for symbol in $data_symbol_list
do
    #echo "#define $symbol @OPJ_MANGLE_PREFIX@_$symbol" >> $OUT_FILE
    echo $symbol | sed 's/.*/#define & @OPJ_MANGLE_PREFIX@_&/' | awk '{printf "%-8s%-40s%s\n", $1, $2, $3}'  >> $OUT_FILE
done

bss_symbol_list=$(objdump -t bin/libopenjpeg.so  | grep "\.bss" | awk '{print $6}' | grep -v "\.")
for symbol in $bss_symbol_list
do
    #echo "#define $symbol @OPJ_MANGLE_PREFIX@_$symbol" >> $OUT_FILE
    echo $symbol | sed 's/.*/#define & @OPJ_MANGLE_PREFIX@_&/' | awk '{printf "%-8s%-40s%s\n", $1, $2, $3}'  >> $OUT_FILE
done

echo "\n#endif" >> $OUT_FILE
echo "\n#endif" >> $OUT_FILE

#rm bin/libopenjpeg.so
