require_relative 'image_optimizer/image_optimizer'
require_relative 'image_optimizer/synchronizer'
require_relative 'image_optimizer/image_hash'
require 'RMagick'

def opt_dir(config)
  config['opt_images'] || 'img/opt'
end

def use_hash(config)
  (config['image_hash'] || 'true')=='true'
end

module Jekyll

  class JekyllImageOptimizer < Generator
    safe true

    def initialize(config)
      @raw=config['raw_images'] || 'img/raw'
      @opt=opt_dir(config)
      @symlink=config['images_link'] || 'images'
      @geometry=config['image_geometry'] || '800x800>'
      @hash=use_hash(config)
    end

    def generate(site)
      io=ImageOptimizer.new(@raw, @opt, @hash)
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
    end

    def render(context)
      s=''
      base_url=context['site']['baseurl']
      index=Liquid::Template.parse(@markup).render(context).to_i
      src=context['page']['image'][index]['url']
      hash=ImageHash.new(use_hash(context['site']))
      for file in Dir[hash.dir_search_pattern(opt_dir(context['site'])+'*', src)]
        if File.file? file and hash.hash? file
          img=Magick::Image.ping(file).first
          s+=base_url+'/'+file+' '+img.columns.to_s+'w,'
        end
      end
      s[0..-2]
    end
  end

  class SrcTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      if markup =~ /\s*(.*?)\s+(.*?)\s*/
        @dir = $1
        @index = $2
      end
    end

    def render(context)
      base_url=context['site']['baseurl']
      index=Liquid::Template.parse(@index).render(context).to_i
      src=context['page']['image'][index]['url']
      hash=ImageHash.new(use_hash(context['site']))
      for file in Dir[hash.dir_search_pattern(opt_dir(context['site'])+@dir, src)]
        if File.file? file and hash.hash? file
          return base_url+'/'+file
        end
      end
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
Liquid::Template.register_tag('src', Jekyll::SrcTag)
Liquid::Template.register_tag('image', Jekyll::ImageTag)