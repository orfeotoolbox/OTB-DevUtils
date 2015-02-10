#!/bin/bash

OTB_TRUNK=~jmalik/dev/src/OTB
OTB_MODULAR=~jmalik/dev/src/OTB-modular

function add_subdir {
  cd $OTB_TRUNK
  find Examples/ -maxdepth 1 -mindepth 1 | sed "s@Examples/@@g" | sed "s@\(.*\)@add_subdirectory(\1)@g" | sort
}

function make_cmakelist {
    d=$1
    cxxlist=$(find $d  -maxdepth 1 -mindepth 1 -type f -name "*.cxx"  | cut -d '/' -f 2 | grep -v "^otb" | sort)
    echo "project(${d}Examples)"
    echo
    for cxx in $cxxlist
    do
      target=$(basename $cxx .cxx)
      echo "add_executable($target $cxx)"
      echo "target_link_libraries($target \${OTB_LIBRAIRIES})"
      echo
    done
    echo
    echo 'if(BUILD_TESTING)'
    echo '  add_subdirectory(test)'
    echo 'endif()'
}

function example_group_cmakelist {
  cd $OTB_TRUNK/Examples
  dirlist=$(find .  -maxdepth 1 -mindepth 1 -type d  | cut -d '/' -f 2 | sort)
  for d in $dirlist
  do
    output=$OTB_MODULAR/Examples/$d/CMakeLists.txt
    make_cmakelist $d > $output
  done
}

function make_test_dirs {
  cd $OTB_MODULAR/Examples
  dirlist=$(find .  -maxdepth 1 -mindepth 1 -type d  | cut -d '/' -f 2 | sort)
  for d in $dirlist
  do
    mkdir $OTB_MODULAR/Examples/$d/test
    touch $OTB_MODULAR/Examples/$d/test/CMakeLists.txt
  done
}


#add_subdir
#example_group_cmakelist
make_test_dirs

