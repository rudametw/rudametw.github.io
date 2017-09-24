#This builds a production site, makes sure urls are correctly set
#Doesn't work because photos are no longer properly built!!!
#jekyll build

jekyll build --watch &

JEKYLL_PID=$!

echo
echo "Jekyll running with PID = $JEKYLL_PID"
echo

#Build clean version of site with production urls
sleep 7
touch index.html

echo "Finished first sleep, site should be valid in a couple of seconds"
sleep 7

echo
echo
echo "Testing length _site/photos/index.html"
echo
LENGTH=`cat _site/photos/index.html | wc -l`
if [[ $LENGTH -lt 10 ]];
then
	echo "Error, photos not properly created, size " $LENGTH
	exit 1
fi

echo
echo
echo "Testing for localhost in _site/sitemap.xml"
echo
#LENGTH=`cat _site/photos/index.html | wc -l`
LENGTH=`grep localhost _site/sitemap.xml | wc -l`
if [[ $LENGTH -gt 0 ]];
then
	echo "Error, localhost is in sitemap.xml, number of occurrences = " $LENGTH
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
'cp' -uvarf _site/* ../ && git add ../ && echo "***** git status *****" && git status  && git commit -m "Update site" && git push

sleep 3
echo "kill $JEKYLL_PID"
kill $JEKYLL_PID
wait
echo "Jekyll finished"
