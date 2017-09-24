#This builds a production site, makes sure urls are correctly set
#Doesn't work because photos are no longer properly built!!!
#jekyll build

jekyll build --watch & 

#Build clean version of site with production urls
sleep 5 && touch index.html

#Update site files
'cp' -uvarf _site/* ../ && git add ../ && echo "***** git status *****" && git status  && git commit -m "Update site" && git push

fg
