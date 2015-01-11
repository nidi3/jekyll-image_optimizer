require_relative 'image_optimizer/image_optimizer'
require 'RMagick'

def opt_dir(config)
  config['opt_images'] || 'img/opt'
end

module Jekyll

  class JekyllImageOptimizer < Generator
    safe true

    def initialize(config)
      @raw=config['raw_images'] || 'img/raw'
      @opt=opt_dir(config)
      @symlink=config['images_link'] || 'images'
      @geometry=config['image_geometry'] || '800x800>'
    end

    def generate(site)
      io=ImageOptimizer.new(@raw, @opt)
      if @geometry.is_a? Enumerable
        @geometry.each { |geom| io.optimize_images(geom) }
      else
        io.optimize_images(@geometry)
        io.create_symlink(@symlink, @geometry)
      end
    end
  end

  class SrcsetTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      @markup
    end

    def render(context)
      s=''
      base_url=context['site']['baseurl']
      index=Liquid::Template.parse(@markup).render(context).to_i
      src=context['page']['image'][index]['url']
      for dir in Dir[opt_dir(context['site'])+'*']
        file = dir+'/'+src
        if File.file? file
          img=Magick::Image::read(file).first
          s+=base_url+'/'+file+' '+img.columns.to_s+'w,'
        end
      end
      s[0..-2]
    end
  end

  class ImageTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      @index = markup.to_i
    end

    def render(context)
      context.stack do
        context['image']=context['page']['image'][@index]
        context['image']['index']=@index
        Liquid::Template.parse(File.read(layout(context))).render(context)
      end
    end

    def layout(context)
      context['site']['image_layout'] || '_layouts/image.html'
    end
  end
end


Liquid::Template.register_tag('srcset', Jekyll::SrcsetTag)
Liquid::Template.register_tag('image', Jekyll::ImageTag)