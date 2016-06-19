# Plotline

Plotline is a flexible CMS engine for Rails apps, based on Postgres, Markdown
and Dropbox. It provides the essentials you need to create any content website:

* Data model for storing your content
* Full-text search engine (Postgres-based)
* Markdown parser with additional features (responsive photosets, custom attributes)
* YAML Front Matter for metadata
* Tags
* Images stored with metadata (exif, width, height)
* Dropbox sync for content files

It comes with a (very) basic admin panel, but it doesn't include any forms
for creating and editing data (yet).

## Getting Started

Best way to get started is to take a look at the
[demo blog app](https://github.com/pch/plotline-demo-blog). Clone the repo, run
the app and make it your own.

For a real-world example of what you can do with Plotline, head over to
[my personal website](http://pchm.co).

* * *

# Usage

Plotline can be used as a part of any Postgres-based Rails app:

```shell
rails new blog --database=postgresql
```

Add Plotline to the Gemfile:

```ruby
gem 'plotline'
```

Run `bundle install` and set up database migrations:

```
rake plotline:install:migrations
rake db:migrate
```

## Content Classes

In order to make use of the CMS engine, you'll need to create a content class
for each of your content type, for example:

```ruby
class BlogPost < Plotline::Entry
  # All classes have "title" and "body" columns, everything else is a content_attr:
  content_attr :subtitle
  content_attr :cover_image
  content_attr :author_name

  searchable_attributes :title, :body
end
```

`Plotline::Entry` serves as a base for all your custom content. It is a regular
ActiveRecord model with additional features, like dynamic content attributes
(without having to write database migrations), full-text search and tags.

* * *

# Features

## Content vs Application Code

Plotline is **not** a static site generator. Plotline-based website is a regular
Ruby on Rails & Postgres application. However, it allows you to store your
Markdown files and images in a Dropbox directory. Any changes you make to that
folder will be imported to the database within seconds.

You can write your content in Markdown using your favorite editor and still get
the benefits and flexibility of a dynamic web application.

### Sync

Dropbox is just a recommended (and tested) method, but Plotline doesn't make any
assumptions regarding the underlying sync technology. It simply monitors the
given source directory for changes and imports them to the database:

```shell
bundle exec plotline sync --source /Users/janedoe/Dropbox/blog
```

**Note:** If you want to use Dropbox sync, keep in mind that **all your files
from the Dropbox directory will be downloaded to the server**. To avoid this, it
is recommended to sign up for a fresh Dropbox account, create a new directory
for your content and share it with your main account. This way, you can link
the app server to the new account and only the content directory will be
downloaded.

## Content Directory Structure

Plotline doesn't enforce a specific structure within the content directory, so
you can arrange files any way you like. Example directory can look like this:

```
media/
  2016/
    hello-world/
      hello.jpg

drafts/
  blog-post-idea.md

blog-posts/
  2016/
    2016-03-25-hello-world.md
```

## Markdown Files Conventions

Markdown files should be named in the following way:

```
YYYY-MM-DD-slug.md
```

The date indicates when the post will be published (future dates are allowed).
The `slug` part will be the url of the post.

Files without a `published_at` date and with a `draft: true` attribute in the
front matter sections are considered drafts:

```markdown
---
title: "Hello World"
type: post
draft: true
---

This is a draft of my new blog post.
```

You can fetch drafts with the following code:

```ruby
@drafts = BlogPost.drafts.order('id DESC')
```

Similarly, published entries should be fetched using the `published` scope:

```
@posts = BlogPost.published.order('published_at DESC')
```

### YAML Front Matter

YAML Front Matter is a special part at the beginning of a Markdown file where
you define metadata attributes:

```markdown
---
title: "Hello World"
type: post
tags:
  - tutorial
  - guide
---

Here goes the actual content.
```

The `title` and `type` attributes are required. Everything else is optional,
but anything you put here should map to a `content_attr` in your content class.

## Custom Markdown

Plotline uses RDiscount as its underlying markdown parser. However, it provides
its own pre-processor for images. It means that Markdown tags like
`![](http://example.com/image.jpg)` will not be parsed by RDicount, but by
plotline's `CustomMarkdownProcessor`.

The idea behind it is to extend basic Markdown images with additional options,
like custom attributes, and responsive photosets (galleries/grids).

For example:

```markdown
![Example image](http://example.com/image.jpg){.center .big #main-img data-behavior=responsive}
```

..will result in the following markup:

```html
<figure class="center big" id="main-img" data-behavior="responsive">
  <img src="http://example.com/image.jpg" />
  <figcaption>Example image<figcaption>
</figure>
```

### Responsive Photosets

Plotline provides an additional, custom Markdown syntax to allow you to create
responsive image galleries. Text enclosed in `--- ... ---` will be parsed as
a photoset block:

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

Continues here.
```

From the example above, Plotline will create a photoset with 3 rows: 2, 1 and 3
images in each row respectively. Empty line marks a new row.

Relative image paths will be replaced and expanded during sync to the database,
so you don't have to worry about keeping a specific directory structure.

## Example Document

```markdown
---
title: "The Adventures of Tom Sawyer"
author: "Mark Twain"
type: post
cover_image: "../../media/hello-world.jpg"
tags:
  - books
  - mark twain
  - adventure
---

![](../../media/posts/tom-sawyer/illustration1.jpg){.center #main-img data-behavior=responsive}

Within two minutes, or even less, he had forgotten all his troubles. Not because
his troubles were one whit less heavy and bitter to him than a man's are to
a man, but because a new and powerful interest bore them down and drove them out
of his mind for the time — just as men's misfortunes are forgotten in the
excitement of new enterprises. This new interest was a valued novelty in
whistling, which he had just acquired from a negro, and he was suffering
to practise it undisturbed. It con- sisted in a peculiar bird-like turn, a sort
of liquid warble, pro- duced by touching the tongue to the roof of the mouth at
short intervals in the midst of the music — the reader probably re- members how
to do it, if he has ever been a boy.

---
![](../../media/posts/tom-sawyer/illustration2.jpg)
![](../../media/posts/tom-sawyer/illustration3.jpg)

![](../../media/posts/tom-sawyer/illustration4.jpg)

![](../../media/posts/tom-sawyer/illustration5.jpg)
![](../../media/posts/tom-sawyer/illustration6.jpg)
---

Diligence and attention soon gave him the
knack of it, and he strode down the street with his mouth full of harmony and
his soul full of gratitude. He felt much as an astronomer feels who has
discovered a new planet — no doubt, as far as strong, deep, unal- loyed pleasure
is concerned, the advantage was with the boy, not the astronomer.
```

* * *


## Parent-child Associations

Content classes can be linked in a parent-child associations:

```ruby
class BlogPost < Plotline::Entry
  child_entries :comments
end

class Comment < Plotline::Entry
  parent_entry :blog_post
end

post = BlogPost.new
post.comments # is the same as:
post.children

comment = Comment.new
comment.blog_post # is the same as:
comment.parent
```

`child_entries` and `parent_entry` methods are merely convinience aliases to
the `has_many :children` and `belongs_to :parent` associations.

## Full-text Search

Plotline comes with a simple Postgres-based full-text search engine. Any content
attribute you list in `searchable_attrs` will be indexed to the `search_data`
table `after_save`:

```ruby
class BlogPost < Plotline::Entry
  searchable_attrs :title, :body
end

BlogPost.published.search("Hello World")
```

## Tags

Tags are stored in the database as Postgres arrays:

```ruby
BlogPost.create(title: "Hello World", tags: ['intro', 'writing'], published_at: Time.now)
BlogPost.published.tagged_with("writing")
```

## Deployment

Rails apps can be a little tedious to deploy, so Plotline provides an example
[Ansible Playbook](https://github.com/pch/plotline-ansible) you can use to
easily set up a server from scratch.

It should run on any Ubuntu 14.04 VPS. Heroku won't work with the
built-in Dropbox sync, due to platform limitations.

* * *

## Known Issues / Limitations

* Image Markdown tags accept only paths/urls to files, the
  `![Caption][image-label]` syntax is not supported.
* For some reason, `<figure>` tags are wrapped in `<p>` tags by RDiscount,
  which may not always be acceptable.
* External images (referenced by URLs) won't store Exif data in the database.
  It should be fairly easy to fix by downloading those images to a temp file
  and passing them to Exiftool. However, I don't use external images, so it
  wasn't a priority to implement. I will happily accept a PR, though.

## License

Plotline is released under the [MIT License](http://www.opensource.org/licenses/MIT).
