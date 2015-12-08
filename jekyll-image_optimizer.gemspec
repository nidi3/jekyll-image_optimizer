Gem::Specification.new do |s|
  s.name        = 'jekyll-image_optimizer'
  s.version     = '1.2.2'
  s.date        = '2015-12-08'
  s.summary     = "A jekyll plugin to optimize images for the web"
  s.description = "The plugin reads all images in a directory and saves optimized versions of them in another directory."
  s.authors     = ["Stefan Niederhauser"]
  s.email       = 'ich@nidi.guru'
  s.files       = ["lib/jekyll/image_optimizer.rb","lib/jekyll/image_optimizer/image_optimizer.rb","lib/jekyll/image_optimizer/synchronizer.rb","lib/jekyll/image_optimizer/image_hash.rb"]
  s.homepage    = 'https://github.com/nidi3/jekyll-image_optimizer'
  s.license     = 'Apache'

  s.add_runtime_dependency('rmagick', '~> 2.13')
end