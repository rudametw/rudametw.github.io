---
layout: blog-post
title: Not enough threads or processes &#58; "thread create failed"
place: Rennes, France
categories: [linux, bug]
---

I started running into a weird problem that I didn't immediately identify. Some programs just started failing: libreoffice, chrome, chromium, firefox, eclipse, ...

It was quite undeterministic and depended on the system ressources being fairly well used. I thought it was a RAM issue, not having enough memory would cause programs to fail. I have somewhat agressive ram settings, but, I also have 16 GB of RAM on my computer. Well, it wasn't a memory issue, I was able to reproduce the issue with loads of memory still left over.

Here's some of the messages I was getting.

*Libreoffice:* (similar bug [here](https://bugs.freedesktop.org/show_bug.cgi?id=73300))
{% highlight bash%}
osl::Thread::create failed
{% endhighlight %}

*Java:*
{% highlight bash%}
java.lang.OutOfMemoryError: unable to create new native thread.
{% endhighlight %}

*Chrome and Chromium:*
{% highlight bash%}
pthread_create error: Resource temporarily unavailable
{% endhighlight %}

<!--more-->

An example of the pthread create bug on another program is here [https://my.vertica.com/docs/5.0/HTML/Master/16468.htm](https://my.vertica.com/docs/5.0/HTML/Master/16468.htm).

Some other side-effect messages appeared like:
{% highlight bash%}
[16751:16780:0408/145921:ERROR:shared_memory_posix.cc(225)] Creating shared memory in /dev/shm/.com.google.Chrome.z77EvR failed: Too many open files
[16751:16780:0408/145921:ERROR:host_shared_bitmap_manager.cc(122)] Cannot create shared memory buffer
{% endhighlight %}

##The FIX
I have all kinds of browsers installed on my computer, and I'm always messing around with their configurations. I'm working on some stuff that requires using different browsers. I also have a lot of open tabs. But this bug appeared whenever I was running Chromium and Google Chrome, making me believe they couldn't be run together. The problem is that with a decent number of tabs both browser start hundreds of threads. Like 500!

Here's some commands to count running threads on your system. Not sure which one is best, they give different answers:
{% highlight bash%}
#Count all threads
ps -elfT | wc -l 
ps -eLf  | wc -l

#Count threads, shows more, don't know why
ps -eLo pid,cmd,nlwp | wc -l
ps axms

#Count threads for different browsers
ps -elfT | grep firefox | wc -l
ps -elfT | grep chrome | wc -l
ps -elfT | grep chromium | wc -l
ps -elfT | grep opera | wc -l
{% endhighlight %}

If you do the test you'll see that chromium and chrome use huge amounts of threads. Right now I have `Chrome@658 threads`, `Chromium@601 threads`, `Firefox@39 threads`, `Opera@4 threads`.

But why is there a limit anyway? Threads are cheap and I have lots of RAM. And, what *is* the limit set at? To find out, we'll use the `ulimit` command.

{% highlight bash%}
#Check max number of threads:
$ ulimit -u
1024

#Check limits for all ressources:
$ ulimit -a
...
{% endhighlight %}

Who the heck came up with 1024 and why?

According to [bug 432903](https://bugzilla.redhat.com/show_bug.cgi?id=432903) this should reduce the risk of forkbombing. But, as explained more recently, it's somewhat useless since a malicious user can still augment the soft thread limit and continue bombing [bug 919793](https://bugzilla.redhat.com/show_bug.cgi?id=919793).

The limit is ancient and should be changed. Here's how to do it.

<br>
####Temporarilly change thread limit:
{% highlight bash%}
#Use about 1 thread per MB of memory
#8 GB
ulimit -u 8192
#16 GB
ulimit -u 16384
{% endhighlight %}

The command works in a shell and is applied to all programs run from that shell. If you open a new shell, the old limit will apply. It sucks when you can't open any more terminals because there's no threads though! In my case, changing the limit immediately allowed me to launch browsers without them crashing.

<br>
####Permanently change thread limit in Fedora 20:
Edit `/etc/security/limits.d/90-nproc.conf`
{% highlight bash%}
# Default limit for number of user's processes to prevent
# accidental fork bombs.
# See rhbz #432903 for reasoning.

#Comment old amount
#*          soft    nproc     1024

#Increase soft amount to 8k threads
*          soft    nproc     8192
*          hard    nproc     16384
root       soft    nproc     unlimited
{% endhighlight %}

This will fix the system. Reboot and voilà.
