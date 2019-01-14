#!/bin/bash
#This builds a production site, makes sure urls are correctly set
#Doesn't work because photos are no longer properly built!!!
#jekyll build

#jekyll build --watch &
bundle exec jekyll build --watch &
JEKYLL_PID=$!

echo
echo "Jekyll running with PID = $JEKYLL_PID"
echo

#Build clean version of site with production urls
sleep 9
sleep 1
echo
echo "***********************"
echo "  REGENERATING PHOTOS"
echo "***********************"
touch index.html
sleep 7
sleep 1

echo
echo
echo "Testing length _site/photos/index.html"
echo
LENGTH=`cat _site/photos/index.html | wc -l`
if [[ $LENGTH -lt 10 ]]  ||  [[ ! -f _site/photos/index.html ]] ;
then
	echo "ERROR, photos not properly created, length " $LENGTH
	#kill $JEKYLL_PID
	trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
	#wait
	exit 1
fi

echo
echo
echo "Testing for localhost in _site/sitemap.xml"
echo
#LENGTH=`cat _site/photos/index.html | wc -l`
LENGTH=`grep localhost _site/sitemap.xml | wc -l`
if [[ $LENGTH -gt 0 ]]  ||  [[ ! -f _site/sitemap.xml ]] ;
then
	echo "ERROR, localhost is in sitemap.xml or sitemap.xml doesn't exist, number of occurrences = " $LENGTH
	#kill $JEKYLL_PID
	trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
	exit 1
fi

echo
echo
echo "**********************"
echo "    VALID SITE"
echo "**********************"
sleep 1

#Copy locally
#'cp' -uvarf _site/* ../
#Update site files, commit and push
'cp' -uvarf --reflink=auto --sparse=always _site/* ../ && echo "REMOVING ../debug.log" && 'rm' ../debug.log && git add ../ && echo "***** git status *****" && git status  && git commit -m "Update site" && git push
#rm ../debug.log

sleep 3
echo
echo "Jekyll was PID $JEKYLL_PID, should be dead"
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
sleep 3
echo
#kill $JEKYLL_PID
#wait
echo "Jekyll finished"

