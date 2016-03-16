module Plotline
  class Engine < ::Rails::Engine
    isolate_namespace Plotline

    require 'jquery-rails'
    require 'rdiscount'
    require 'mini_magick'
    require 'thumbor_rails'

    require 'bourbon'
    require 'autoprefixer-rails'
  end
end
