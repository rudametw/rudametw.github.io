        // to defear the loading of stylesheets
        // just add it right before the </body> tag
        // and before any js inclusion (for performance)  
        function loadStyleSheet(src){
            if (document.createStyleSheet) document.createStyleSheet(src);
            else {
                var stylesheet = document.createElement('link');
                stylesheet.href = src;
                stylesheet.rel = 'stylesheet';
                stylesheet.type = 'text/css';
                document.getElementsByTagName('head')[0].appendChild(stylesheet);
            }
        }
