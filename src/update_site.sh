#This builds a production site, makes sure urls are correctly set
jekyll build

'cp' -uvarf _site/* ../ && git add ../ && echo "***** git status *****" && git status  && git commit -m "Update site" && git push
