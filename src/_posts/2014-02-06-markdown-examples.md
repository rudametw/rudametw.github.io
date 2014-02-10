---
layout: blog-post
title: Testing different markup options
place: Rennes, France
categories: [markdown, untidy]
---

This post is a test for markdown and Jekyll. I basically have all kinds of examples of how to do stuff in markdown, but it's not tidy at all.

<!--more-->

Markup syntax can be found here\:  
[http://daringfireball.net/projects/markdown/syntax](http://daringfireball.net/projects/markdown/syntax)  
[https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

This is [an example](http://example.com/ "Title") inline link.  
[This link](http://example.net/) has no title attribute.

<p> Regular text goes here. Just messing around with this darn thingity and it seems to be doing ok</p>


<!-- <img src="/img/dolphins.jpg" class="img-responsive"> -->
<!-- <hr> -->


<p class="lead"> Second part, this is the lead part of the text, most likely the excerpt.</p>

<p><strong>Placeholder text by:</strong>
</p>
<ul>
	<li><a href="http://spaceipsum.com/">Space Ipsum</a>
	</li>
	<li><a href="http://cupcakeipsum.com/">Cupcake Ipsum</a>
	</li>
</ul>

<hr>


{% highlight java linenos%}
public static void main(String[] args)
{
	int[] list ={1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	int sum = sumListEnhanced(list);
	System.out.println("Sum of elements in list: " + sum);

	System.out.println("Original List");
	printList(list);
	System.out.println("Calling addOne");
	addOne(list);
	System.out.println("List after call to addOne");
	printList(list);
	System.out.println("Calling addOneError");
	addOneError(list);
	System.out.println("List after call to addOneError. Note elements of list did not change.");
	printList(list);
}
{% endhighlight %}


1. First ordered list item
2. Another item
  * Unordered sub-list. 
1. Actual numbers don't matter, just that it's a number
  1. Ordered sub-list
4. And another item.

   You can have properly indented paragraphs within list items. Notice the blank line above, and the leading spaces (at least one, but we'll use three here to also align the raw Markdown).

   To have a line break without a paragraph, you will need to use two trailing spaces.⋅⋅
   Note that this line is separate, but within the same paragraph.⋅⋅
   (This is contrary to the typical GFM line break behaviour, where trailing spaces are not required.)

* Unordered list can use asterisks
- Or minuses
+ Or pluses


# Hello World

Proin eleifend libero accumsan felis luctus nec consectetur purus commodo. \
Phasellus sodales est nec massa imperdiet commodo. Maecenas risus nulla, pl\
acerat vel vestibulum vel, dapibus quis libero.

Donec libero libero, bibendum non condimentum ac, ullamcorper at sapien. Du\
is feugiat urna vel justo cursus facilisis. Vivamus ligula dui, convallis a\
varius vitae, facilisis eget magna.


This should not be quoted.

> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
> 
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.

#### This should not be quoted.


> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.

#### This should not be quoted.

> This is the first level of quoting.
>
> > This is nested blockquote.
>
> Back to the first level.

#### This should not be quoted.


> ## This is a header.
> 
> 1.   This is the first list item.
> 2.   This is the second list item.
> 
> Here's some example code:
> 
>     return shell_exec("echo $input | $markdown_script");


Unordered lists use asterisks, pluses, and hyphens — interchangably — as list markers:

*   Red
*   Green
*   Blue
is equivalent to:

+   Red
+   Green
+   Blue
and:

-   Red
-   Green
-   Blue


Ordered lists use numbers followed by periods:

1.  Bird
2.  McHale
3.  Parish

If you instead wrote the list in Markdown like this:

1.  Bird
1.  McHale
1.  Parish


To make lists look nice, you can wrap items with hanging indents:

*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.


{% highlight bash %}
cd ~
{% endhighlight %}
