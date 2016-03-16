# Plotline

Plotline is a flexible CMS engine for Rails apps, based on Markdown and Postgres. It allows you to store content in markdown files on Dropbox (for seamless, instant sync), separating content from your application code.

More soon.

## Getting Started

Best way to get started is to take a look at the [demo blog app](https://github.com/pch/plotline-demo-blog). Clone the repo, run the app and make it your own.

## Custom Markdown

Plotline uses RDiscount as its underlying markdown parser. However, it provides its own pre-processor for images. That means markdown tags like `![](http://example.com/image.jpg)` will not be parsed by RDicount, but by plotline's `CustomMarkdownProcessor`.

The idea behind it is to extend basic Markdown images with additional options, like custom attributes, and responsive photosets (photo grids).

For example:

```markdown
![Example image](http://example.com/image.jpg){.center #main-img data-behavior=hero}
```

..will result in the following markup:

```html
<figure class="center" id="main-img" data-behavior="hero">
  <img src="http://example.com/image.jpg" />
  <figcaption>Example image<figcaption>
</figure>
```

### Responsive Photosets

Plotline provides an additional, custom Markdown syntax to allow you to create responsive image galleries. Text enclosed in `--- ... ---` will be parsed as a photoset block:

```markdown
Here are the photos from my trip:

---
![](../../media/posts/hello/photo1.jpg)
![](../../media/posts/hello/photo2.jpg)

![](../../media/posts/hello/photo3.jpg)

![](../../media/posts/hello/photo4.jpg)
![](../../media/posts/hello/photo5.jpg)
![](../../media/posts/hello/photo5.jpg)
---

Rest of your text goes here.
```

From the example above, Plotline will create a photoset with 3 rows: 2, 1 and 3 images in each row respectively. Empty line is treated as a new row.

## Example Document

```markdown
---
title: "Hello World"
type: post
tags:
  - intro
  - example
---

![](../../media/posts/the-shining/overlook.jpg){.center #main-img data-behavior=hero}

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

---
![](../../media/posts/hello/photo1.jpg)
![](../../media/posts/hello/photo2.jpg)

![](../../media/posts/hello/photo3.jpg)

![](../../media/posts/hello/photo4.jpg)
![](../../media/posts/hello/photo5.jpg)
---

And this is it!

```

## License

Plotline is released under the [MIT License](http://www.opensource.org/licenses/MIT).
