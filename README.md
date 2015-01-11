# jekyll-image_optimizer
A jekyll plugin to optimize images for the web.
It reads all the images in a source directory and saves optimized versions of them to a destination directory
and creates a symbolic link to the destination directory.

Install it with `gem install jekyll-image_optimizer`.

Add this to your `plugins/ext.rb` file: `require 'jekyll/image_optimizer'`.

The following options for `_config.yml` are available:

  - `raw_images` the directory containing the unoptimized images, default is `img/raw`.
  - `opt_images` the directory containing the optimized images, default is `img/opt`.
  - `images_link` the name of the symbolic link pointing to `opt_images`, default is `images`.
  - `image_geometry` the size all images should be, is an ImageMagick [geometry string](http://www.imagemagick.org/RMagick/doc/imusage.html#geometry), may be an array, default is `800x800>`.
  - `image_layout` the file containing the template for the `image` tag, default is `_layouts/image.html`.

The plugin defines two liquid tags: `srcset` and `image`.
To include an image with multiple resolutions (using [scrset](http://ericportis.com/posts/2014/srcset-sizes/)) into a post, do the following:

In `_layouts/image.html` define the template of an image. For example:
```
<img srcset="{% srcset {{image.index}} %}" alt="{{image.alt}}"/>
```

In the front matter of the post, add
```
image:
    -   url: my_image.jpg
        alt: My Alt
```

and reference the image using `{% image 0 %}` where 0 is the index of the image.

