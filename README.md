# Plotline

Plotline is a flexible CMS engine for Rails apps, based on Postgres and Markdown. It provides the essentials you need to create any content website:

* Data model for storing your content
* Full-text search engine (Postgres-based)
* Markdown parser with custom features (photosets, custom attributes)
* Tags
* Images stored with metadata (exif, width, height)
* Parent-child associations for content entries

It also provides a basic admin panel. However, it doesn't include any forms for creating and editing data.

The idea was to allow for storing content in plain markdown files on Dropbox (for seamless, instant sync), separating content from your application code. You can write your blog posts in your favorite editor, put the file in the Dropbox folder along with images and Plotline will automatically pick it up. Any changes you make to your Dropbox folder will be synced within seconds.

## Getting Started

Best way to get started is to take a look at the [demo blog app](https://github.com/pch/plotline-demo-blog). Clone the repo, run the app and make it your own.

## Creating Custom Content Classes

Plotline provides the `Plotline::Entry` class, which serves as the base for your custom content types:

```ruby
class BlogPost < Plotline::Entry
  # All classes have "title" and "body" columns, everything else is a content_attr:
  content_attr :subtitle
  content_attr :cover_image
end
```

Custom `content_attrs` are stored as serialized JSON in the database. There's no need to run any additional migrations, thanks to [Single Table Inheritance](http://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html) (everything is stored in a single database table).

## Content Directory Structure

Example directory with content:

```
media/
  2016/
    hello-world/
      hello.jpg

drafts/
  researched-blog-post.md

blog-posts/
  2016/
    2016-03-25_hello-world.md
```

The only required directories are `media` and `drafts`. Plotline doesn't enforce structure within directories, though, so you can arrange files any way you like.

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
Here are the photos from my last trip:

---
![](../../media/posts/hello/photo1.jpg)
![](../../media/posts/hello/photo2.jpg)

![](../../media/posts/hello/photo3.jpg)

![](../../media/posts/hello/photo4.jpg)
![](../../media/posts/hello/photo5.jpg)
![](../../media/posts/hello/photo5.jpg)
---

Beautiful, huh?
```

From the example above, Plotline will create a photoset with 3 rows: 2, 1 and 3 images in each row respectively. Empty line is treated as a new row.

## Example Document

```markdown
---
title: "Hello World"
type: post
cover_image: '../../media/hello-world.jpg'
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

The End.
```

## Known Issues / Limitations

* Image Markdown tags accept only paths/urls to files, the `![Caption][image-label]` syntax is not supported
* Figure tags are wrappend in `<p>` tags by RDiscount, which may not always be acceptable
* External images (referenced by URLS) won't store Exif data in the database.  It should be fairly easy to fix by downloading those images to a temp file and passing them to Exiftool. However, I don't use external images, so it wasn't a priority to implement. I will happily accept a PR, though.

## License

Plotline is released under the [MIT License](http://www.opensource.org/licenses/MIT).
