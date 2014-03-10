---
layout: blog-post
title: Thunderbird bug&#58; leading spaces are removed when character set is automatically converted
place: Rennes, France
categories: [thunderbird, bug]
---

I ran into a weird bug that took me about 50 test emails to understand. Thunderbird appears to automatically convert your plain-text emails from one character set to another automatically if it detects that there is an incompatible character.

However, the conversion isn't as smooth as it should be. In fact, in my case, all leading spaces in my neatly formatted plain-text format=flowed emails disappear.

<!--more-->

Let's try an example. Send an email with a couple of lines and a single "weird" character, like this one:

{% highlight bash%}
    This line has four leading spaces
   This line has three leading spaces
          This line has ten leading spaces

’ This is a stupid right-single-quotation-mark character (u+2019)
{% endhighlight %}

And what do we get when we send it?

{% highlight bash%}
Return-Path: walter.rudametkin@inria.fr
[...]
Message-ID: <531727D5.7000209@inria.fr>
Date: Wed, 05 Mar 2014 14:34:13 +0100
From: Walter Rudametkin <walter.rudametkin@inria.fr>
Organization: INRIA
User-Agent: blabla
MIME-Version: 1.0
To: undisclosed-recipients:;
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

This line has four leading spaces
This line has three leading spaces
This line has ten leading spaces

’ This is a stupid right-single-quotation-mark character (u+2019)
{% endhighlight %}

Damn, where are my spaces?

##What's going on?

My charset in Thunderbird was configured to `ISO-8859-1`, which appears to still be the default. Thunderbird doesn't appear to be willing to change to UTF-8 as a default either, as can be seen by the WONTFIX in this [bug](https://bugzilla.mozilla.org/show_bug.cgi?id=224391).

Behind the scenes Thunderbird sees the "weird" character and changes the character set to a compatible one when sending the email. 

This can be seen in my 'Content-Type' header which becomes this:

{% highlight bash linenos%}
Content-Type: text/plain; charset=windows-1252; format=flowed
{% endhighlight %}

As you can see, the charset is now changed to 'windows-1252' (instead of the default 'ISO-8859-1'), but my spaces are also gone!!!

Furthermore, if you use utf-8 characters like ←→⇐⇒⇑⇓⇙⇗⇖⇘⇙, which I conveniently have my keyboard setup to use, your email will be converted to 'charset=UTF-8', and you still lose your leading spaces.

## Solution

My solution is to simply set Thunderbird to always use 'UTF-8'. In Thunderbird this is pretty simple, go to:
`Edit→Preferences→Display→Advanced` And change outgoing and incoming mails.

## Mozilla bug

If anybody is intested, I filed a bug for this problem [https://bugzilla.mozilla.org/show_bug.cgi?id=979857](https://bugzilla.mozilla.org/show_bug.cgi?id=979857)
