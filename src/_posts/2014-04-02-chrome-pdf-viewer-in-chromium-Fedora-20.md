---
layout: blog-post
title: Add Chrome PDF Viewer to Chromium on Fedora 20 x86_64
place: Rennes, France
categories: [linux, chromium, feature]
---

I really would like a PDF reader that saves the open pdf files in tabs, like a browser does. It would let me get back to reading whatever I was reading after a restart. Currently, I try to restart as little as possible, usually between 20 and 40 days in order to save all my open stuff. I would use Mendeley except the open tabs feature request has been open since 2009 and not implemented yet!!! [http://feedback.mendeley.com/forums/4941-general/suggestions/263198-remember-open-tabs-and-position-within-pdfs](http://feedback.mendeley.com/forums/4941-general/suggestions/263198-remember-open-tabs-and-position-within-pdfs).

My answer for PDFs is to use my browser to store my open files. It might be a little overkill but it does the job decent enough. I mainly use Firefox + mozplugger + evince, but I also use the Chrome and Chromium browsers for different things including reading PDFs. Chrome has a simple PDF plugin that I like and its pretty fast, but Chromium doesn't have it because of licensing issues.

<!--more-->

On Fedora 20 x86_64, here's how to include the plugin into Chromium if you have both browsers installed:
{% highlight bash%}
ln -s /opt/google/chrome/libpdf.so /usr/lib64/chromium/libpdf.so
{% endhighlight %}

I prefer the symbolic link because when Chrome updates the plugin, Chromium automatically gets the updated version. If you don't like that or if you don't install Chrome, just copy the libpdf.so file into Chromium.

Go to chrome://plugins/ to enable the plugin or to see if Chromium actually finds it.
