---
layout: blog-post
title: NSLU Linux Gateway
place: Rennes, France
categories: [linux, nslu2]
---

<img class="center-block" src="/img/nslu2.jpg" alt="NSLU2.jpg"/>

It's easy to setup additional IP addresses on Debiann Linux. This is particularly useful for the NSLU which doesn't have a display so you need to remotely connect to it.

<!--more-->


###On the nslu
IP address must be setup. Also, a DNS must be configured in order to work.

Once you can ping the gateway machine, the gateway must be added so that the nslu knows that he can attain addresses that are beyond his own network.

Command is 
{% highlight bash%}
	route add default gw 192.168.0.100
{% endhighlight %}

Then the `/etc/resolv.conf` must be edited to the same nameserver as the other box. Note that nslu should be able to ping this nameserver once the gateway is setup.

For setting up the gateway we must enable ip forwarding:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

If we want to setup alias cards, we can do
ifconfig eth0:N address    netmask

{% highlight bash%}
iface eth0:0 inet static
		address 192.168.0.100
		netmask 255.255.255.0
		broadcast 192.168.0.255
		network 192.168.0.0
		pre-up echo "*** Starting eth0:0 alias ***"
		post-up echo "*** Alias eth0:0 started ***"
		#post-up route add -net 192.168.0.0 dev eth0
		#post-up route add -host 192.168.0.10 dev eth0:1
{% endhighlight %}

or inside the interfaces file doing

finally, must set up iptables to the correct rules!!!
Rules are defined in /home/rudametw/bin/ip_forwarding

