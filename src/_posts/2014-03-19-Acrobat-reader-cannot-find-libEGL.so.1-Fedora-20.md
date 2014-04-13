---
layout: blog-post
title: Acrobat reader cannot find libEGL.so.1 &#58; Fedora 20
place: Rennes, France
categories: [linux, bug]
---

I use acrobat reader sometimes, like when people send me an annotated pdf or if Evince doesn't print it properly. My main pdf reader is Evince, but it's a bit buggy. Also, I use okular to annotate pdfs, which it does a fine job at.

Anyhow, I was getting the following error after applying some updates: 

{% highlight bash%}
acroread: error while loading shared libraries: libEGL.so.1: cannot open shared object file: No such file or directory
{% endhighlight %}

It took me a while to track down the problem, which has a simple solution, just find the missing symbolic link. I ran into this page that describes the issue but nobody had provided the proper command [http://forums.fedoraforum.org/showthread.php?t=297151](http://forums.fedoraforum.org/showthread.php?t=297151).

<!--more-->

Acroread is x86 32 bits but I'm running Fedora 20 x86_64, so I didn't see initially that my libEGL that I was trying to link with was the wrong one. Anyhow, make sure you have the right libEGL installed: 

{% highlight bash%}
#List the files
repoquery --list mesa-libEGL.i686
#Install or reinstall just to make sure
yum reinstall  mesa-libEGL.i686
{% endhighlight %}

Fedora uses different lib directory for 32 and 64 bit binairies. We want to point to the 32 bit one, so the command to fix acroread is:
{% highlight bash%}
ln -s /usr/lib/libEGL.so.1 /opt/Adobe/Reader9/Reader/intellinux/lib/libEGL.so.1
{% endhighlight %}


