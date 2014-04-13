---
layout: blog-post
title: Fr alternative keyboard layout bug (fr-oss)&#58; right ctrl key not working
place: Rennes, France
categories: [linux, bug]
---

I really like the 'alternative' french keyboard layout on my computer, a.k.a fr-oss. I like to use the deadkeys for accents in french and spanish, and I really like the alt-gr + ctrl# for doing arrows and stuff like that.

Earlier this year on my Fedora laptop (F20) for work the right ctrl key stopped working. It sucked because ctrl-arrows no longer jump through words in text documents. VLC right ctrl+Up/Down no longer changed the volume either, making me have to use both hands just for that. I figured it was a bug in Fedora so I found a neat command to fix the mapping while I waited for the problem to be fixed. However, some time later it happened to my wife's Ubuntu laptop and looking into it I found that the problem is comes from higher up the chain.

Someone decided to map right ctrl to something "new" instead of letting it be the same as the left ctrl key. Sure, if programs used the "new right control" it might be great and super useful. But they don't, so the key does nothing. Kind of beats the purpose, huh?

[https://bugs.freedesktop.org/show_bug.cgi?id=15804#c44](https://bugs.freedesktop.org/show_bug.cgi?id=15804#c44)

To fix the problem, here's the command you can run.

{% highlight bash%}
xmodmap -e 'keycode 105 = Control_R' -e 'clear Control' -e 'add Control = Control_L Control_R'
{% endhighlight %}

However...

<!--more-->

the command needs to be run every time the machine is started. I figured I'd put it into a startup script and voilà! WRONG, sometimes after suspend/resume the key just stops working again. Or, when I connect the computer to my dock station and use the external monitors + keyboard + mouse, it also stops working.

I was going to do a cronjob or a script that ties into resume, but instead, I mapped a shortcut in XFCE to execute my script and notify me when it does. Pretty simple, the shortcut I used is `<meta> + k` (the windows key + k). The script is as follows:

{% highlight bash%}
#!/bin/sh
notify-send -u normal -t 1000 "Fixing right control key"
xmodmap -e 'keycode 105 = Control_R' -e 'clear Control' -e 'add Control = Control_L Control_R'
{% endhighlight %}

The only *weird* thing is that it doesn't always work on the first try. Or the second. Or the third. But, if you hit `meta + k` enough, it'll work. I don't know why that is, on the command line it works on the first try every time, but with the shortcut it just is.
