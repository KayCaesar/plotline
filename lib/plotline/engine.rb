module Plotline
  class Engine < ::Rails::Engine
    isolate_namespace Plotline

    require 'jquery-rails'
    require 'rdiscount'
    require 'fastimage'
    require 'exiftool'

    require 'bourbon'
    require 'autoprefixer-rails'
  end
end
