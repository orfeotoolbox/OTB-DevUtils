#!/bin/bash
# Script qui liste les fichiers .h d'un répertoire et de ses sous répertoires

#-----------------------
#-----------------------
# MAIN
echo start
echo input1=$1
echo input2=$2

INPUT_PATH=$1

echo "Monolithic OTB file name, Monolithic OTB current directory, Group name, Module name, Subdir in the module" > $2

# liste des répertoires
DIR_LIST=$(ls -d $1*/ 2> /dev/null) 
echo DIR_LIST=$DIR_LIST  

for DIR in $DIR_LIST
do
    echo "--------"
    echo DIR=$DIR

    DIR_R=${DIR#${INPUT_PATH}}
    DIR_R2=${DIR_R%/}
    FILE_PATH_LIST=$(ls ${DIR}*.{h,txx,cxx} 2> /dev/null)
    #echo FILE_PATH_LIST=$FILE_PATH_LIST
    for FILE_PATH in $FILE_PATH_LIST 
    do
        if [[ "$FILE_PATH" = *".h"* ]]
        then
              OUTPUT_DIR='include'
        elif [[ "$FILE_PATH" = *".txx"* ]]
        then
              OUTPUT_DIR='include'
        elif [[ "$FILE_PATH" = *".cxx"* ]]
        then
              OUTPUT_DIR='src'
        else
              echo error 
        fi

        FILE_PATH_R=${FILE_PATH#${INPUT_PATH}}
        echo ./Code/$FILE_PATH_R , $DIR_R2 , , , $OUTPUT_DIR  >> $2
    done

    #try to read the content of the subdir
    LIST_SUB_DIR=$(ls -d $DIR*/ 2> /dev/null) 
    #echo $LIST_SUB_DIR
    for SUB_DIR in $LIST_SUB_DIR 
    do
        echo SUB_DIR=$SUB_DIR
        SUB_DIR_R=${SUB_DIR#${INPUT_PATH}}
        SUB_DIR_R2=${SUB_DIR_R%/}
        FILE_PATH_LIST2=$(ls ${SUB_DIR}*.{h,txx,cxx} 2> /dev/null)
        for FILE_PATH2 in $FILE_PATH_LIST2 
        do
            if [[ "$FILE_PATH2" = *".h"* ]]
            then
                  OUTPUT_DIR2='include'
            elif [[ "$FILE_PATH2" = *".txx"* ]]
            then
                  OUTPUT_DIR2='include'
            elif [[ "$FILE_PATH2" = *".cxx"* ]]
            then
                  OUTPUT_DIR2='src'
            else
                  echo error 
            fi

            FILE_PATH_R2=${FILE_PATH2#${INPUT_PATH}}
            echo ./Code/$FILE_PATH_R2 , $SUB_DIR_R2, , , $OUTPUT_DIR2 >> $2
        done
    done    
done

