desc "Import entries"
task :import_entries => :environment do
  path   = ENV.fetch('CONTENT_SOURCE_DIR')
  target = ENV.fetch('APP_DIR')
  excluded_directories = ['.', '..', 'media', 'drafts']

  importer = Plotline::Importer.new(path, target)

  if ENV['FILE'].present?
    importer.import_file(ENV['FILE'])
  else
    directories = Dir.entries(path).select { |file| File.directory?(File.join(path, file)) }
    directories = directories.reject { |d| excluded_directories.include?(d) }

    puts "Found:"
    p directories

    directories.each do |dir|
      Dir["#{path}/#{dir}/**/*.md"].each do |filename|
        importer.import_file(filename)
      end
    end
  end
end

task :import_images => :environment do
  path   = ENV.fetch('CONTENT_SOURCE_DIR')
  target = ENV.fetch('APP_DIR')
  importer = Plotline::Importer.new(path, target)

  puts "Importing images..."
  importer.import_images
end
