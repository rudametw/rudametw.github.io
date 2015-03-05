#!/bin/bash

#optimize() {
#  cd _site
#  jpegoptim *.jpg --strip-all
#  for i in *
#  do
#    if test -d $i
#    then
#      cd $i
#      echo $i
#      optimize
#      cd ..
#    fi
#  done
#  echo
#}
#optimize

STDIR=$PWD;
IFS=$'\n';
for dir in $(find _site/ -type d); do 
    cd $dir;
    echo "Checking: `pwd`"

    files=$(ls *.jpg 2> /dev/null | wc -l)
    if [ "$files" != "0" ]; then
#        echo "*******************************"
        echo "Found jpg $files in `pwd`"
#        jpegoptim --max=50 --strip-all --preserve --totals *.jpg;
        jpegoptim --max=50 --strip-all --preserve --totals *.jpg;
    fi

    files=$(ls *.JPG 2> /dev/null | wc -l)
    if [ "$files" != "0" ]; then
        echo "*******************************"        
        echo "Found JPG $files in `pwd`"
        jpegoptim --max=50 --strip-all --preserve --totals *.JPG
    fi

#    files=$(ls *.png 2> /dev/null | wc -l)
#    if [ "$files" != "0" ]; then
#        echo "*******************************"        
#        echo "Found png $files in `pwd`"
#        #jpegoptim --max=90 --strip-all --preserve --totals *.png
#        #for i in *.png; do optipng -o5 -quiet -keep -preserve -log optipng.log "$i"; done
#        #for i in *.png; do optipng -o5 -preserve -clobber "$i"; done        
#        for i in *.png; do optipng -o7 -preserve -clobber "$i"; done        
#        echo "Found pngs but not optimizing them"
#    fi

    echo

    cd $STDIR; 
done; 
unset IFS

