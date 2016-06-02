$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plotline/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plotline"
  s.version     = Plotline::VERSION
  s.authors     = ["Piotr Chmolowski"]
  s.email       = ["piotr@chmolowski.pl"]
  s.homepage    = "https://github.com/pch/plotline"
  s.summary     = "Markdown & Postres-based CMS engine for Rails."
  s.description = "Markdown & Postres-based CMS engine for Rails."
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.3.0"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.executables = ["plotline"]

  s.add_dependency "rails", "~> 5.0.0.rc1"
  s.add_dependency "bcrypt", "~> 3.1.7"
  s.add_dependency "sass-rails", "~> 5.0"

  s.add_dependency "jquery-rails"
  s.add_dependency "autoprefixer-rails"
  s.add_dependency "bourbon"

  # Files & images
  s.add_dependency "fastimage"
  s.add_dependency "exiftool"

  # Markdown
  s.add_dependency "rdiscount"

  # File sync
  s.add_dependency "commander"
  s.add_dependency "listen"

  s.add_development_dependency "pg"
end
