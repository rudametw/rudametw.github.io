---
layout: blog-post
title: Reduce touchpad sensitivity on a Dell e6430
place: Rennes, France
categories: [linux, feature]
---

I find the touchpad on my laptop way to sensitive by default. To change it, I've found the following settings comfortable:

{% highlight bash%}
xinput set-prop "AlpsPS/2 ALPS DualPoint TouchPad" "Synaptics Finger" 18 18 18
{% endhighlight %}

I also have a wireless mouse that I sometimes use. It's way to sensitive. The following command makes it useable:
{% highlight bash%}
xinput set-prop "HP Wireless Optical Mobile Mouse" "Device Accel Adaptive Deceleration" 1.5
{% endhighlight %}
