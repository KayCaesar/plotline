module Plotline
  class Configuration
    attr_accessor :content_classes

    def initialize
      @content_classes = [].freeze
    end

    def logger(logger = nil)
      @logger ||= logger || Logger.new(STDOUT)
      @logger
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
