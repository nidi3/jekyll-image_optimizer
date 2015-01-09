require_relative 'synchronizer.rb'
require 'RMagick'

class ImageOptimizer < Synchronizer
  def initialize(source_path, target_path)
    super(source_path, target_path)
  end

  def optimize_images(geometry)
    synchronize(geometry)
  end

  def target_name(path, geometry)
    path+geometry.gsub('>', 'max').gsub('<', 'min').gsub('@', 'area')
  end

  def do_synchronize_file(source, target, param)
    if process? source
      puts "optimizing #{source} -> #{target}"
      optimize_image(source, target, param)
    else
      puts "copying #{source} -> #{target}"
      copy_file(source, target)
    end
  end

  def optimize_image(source, target, geometry)
    image = Magick::Image.read(source).first
    image.change_geometry!(geometry) { |cols, rows, img|
      img.resize!(cols, rows)
      img.strip!
      img.write('jpeg:'+target)
    }
  end

  def process?(file)
    file.downcase.end_with? '.jpg' or file.downcase.end_with? '.jpeg'
  end

end

# io=ImageOptimizer.new('img/a', 'img/opt')
# io.optimize_images('300x300>')
# io.create_symlink('images', '300x300>')