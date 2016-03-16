ThumborRails.setup do |config|
  config.server_url = ENV.fetch('THUMBOR_URL')
  config.security_key = ENV['THUMBOR_SECURITY_KEY'] # not required in development
end
