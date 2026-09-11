---
url: /blog/posts/2011.09.17/Linux-webdav-box.net.html
layout: blog-post
title: Mount your Box.Net account using WebDAV
place: Grenoble, France
categories: [linux, webdav, cloud]
---

It's pretty easy to setup box.net with webdav and to have your files automatically saved to box.net. I got 50gb of storage space on box.net when I bought an HP Touchpad 32gb on firesale.

However, because it's not a paid or professional account, I can't really do anything with it.

UPDATE: I don't use this setup because box.net is just too slow and some people have been complaining that they don't implement webdav properly. I really wish they'd come up with a client for Linux like Dropbox has.

Originally posted on Ubuntu Forums: [http://ubuntuforums.org/showthread.php?t=202761&page=4](http://ubuntuforums.org/showthread.php?t=202761&page=4)

<!--more-->

## Davfs setup

I just setup my box.net and wanted to share the steps with anybody having trouble. I suppose you've installed davfs already.

Create a mount point:

```bash
	mkdir ~/box.net
```

Add this to `/etc/fstab` (correct the details for your user):
```bash
	http://www.box.net/dav /home/user/box.net davfs rw,user,noauto 0 0
```

(Just as a note, https didn't work for me. It mounts but copied files never showed up. I saw something on their site about 256bit SSL encryption being available when you upgrade to business.)

To allow your your user to mount without being root you want to say yes to this:
```bash
sudo dpkg-reconfigure davfs2
```

Then add user to davfs2 group
```bash
sudo adduser $USER davfs2
```


Let's configure davfs in your home directory
```bash
mkdir ~/.davfs2
cp /etc/davfs2/davfs2.conf ~/.davfs2
```

Add this to `~/.davfs2/davfs2.conf`:

```bash
use_locks       0
```

To avoid typing your login and password every time:
```bash
sudo cp /etc/davfs2/secrets ~/.davfs2
sudo chown $USER ~/.davfs2/secrets
```

Add your login and pass to `~/.davfs2/secrets`:
```bash
http://www.box.net/dav	username@mail.com	password
```

And finally mount:

```bash
mount ~/box.net
```

I hope I didn't miss anything. I used some stuff originally found in french here: [http://doc.ubuntu-fr.org/davfs2](http://doc.ubuntu-fr.org/davfs2)

### Rsync and Box.net
I've been running rsync for a little while and ever since I got the configuration correct (i.e., nolocks, http) I haven't had any trouble. 

On the other hand, I want better synchronization so instead of rsync (or even Unison) I'm thinking of using something like dvcs-autosync or SparkleShare because they use a git backend and provide version control (among other features), but I haven't figured out how to set it up so that I can put the "central" .git repo on my box.net. (Maybe it's really simple.) Also, lots of my files are photos & music and I'm not sure if using git on them is a good idea.

[http://www.syncany.org/](http://www.syncany.org/) might be an interesting option, they say they provide synchronization for local folders (including nfs and fuse mounts) out of the box, but the project doesn't seem very mature yet.

