require_relative 'image_optimizer/image_optimizer'

module Jekyll

  class JekyllImageOptimizer < Generator
    safe true

    def initialize(config)
      @raw=config['raw_images'] || 'img/raw'
      @opt=config['opt_images'] || 'img/opt'
      @symlink=config['images_link'] || 'images'
      @geometry=config['image_geometry'] || '800x800>'
    end

    def generate(site)
      io=ImageOptimizer.new(@raw, @opt)
      io.optimize_images(@geometry)
      io.create_symlink(@symlink, @geometry)
    end
  end
end