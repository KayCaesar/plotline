module Plotline
  class Importer
    FILENAME_SPLIT_PATTERN = /^(\d{4}-\d{2}-\d{2})-(.*)/
    FRONT_MATTER_PATTERN = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

    def initialize(source_dir, target_dir)
      @source_dir = source_dir
      @target_dir = target_dir
      @media_dir  = target_dir + '/public/media'
    end

    def import_file(filename)
      dir = filename.gsub(@source_dir + '/', '').split('/').first
      basename = File.basename(filename, ".*")

      puts "Importing: #{filename}"

      date, slug = basename.split(FILENAME_SPLIT_PATTERN).reject { |m| m.blank? }
      if slug.blank?
        slug = date
        date = nil
      end

      contents = File.read(filename)
      contents = contents.gsub('../../media', '/media') # replace relative img paths
      checksum = Digest::MD5.hexdigest(contents)

      if result = contents.match(FRONT_MATTER_PATTERN)
        contents = contents[(result[0].length)...(contents.length)]
        meta = YAML.safe_load(result[0])
      end

      if meta['type'].blank?
        raise "Missing 'type' attribute in #{filename}"
      end
      klass = meta.delete('type').classify.constantize

      entry = klass.find_or_initialize_by(slug: slug)
      if entry.checksum == checksum
        puts "File unchanged, skipping."
        return
      end

      draft = !!meta.delete('draft')
      entry.status = draft ? :draft : :published

      entry.assign_attributes(meta.merge(
        body: contents,
        checksum: checksum,
        published_at: (Date.parse(date) if date && !draft)
      ))
      entry.save!

      dump_log(entry, meta)
    end

    def import_images
      Dir[@media_dir + '/**/*.{jpg,jpeg,png,gif,bmp,tiff}'].each do |img|
        filename = img.gsub(@media_dir + '/', '')

        image = Plotline::Image.find_or_initialize_by(image: filename)
        next if image.persisted? && File.size(img) == image.file_size

        image.save!
      end
    end

    private

    def dump_log(entry, meta)
      puts
      puts "\nMetadata:"
      meta.each do |k, v|
        puts "  #{k}: #{v}"
      end

      puts "\n#{entry.class.name}:"
      puts "  title: #{entry.title}"
      puts "  slug: #{entry.slug}"
      puts "  draft: #{entry.draft?}"
      puts "  published_at: #{entry.published_at}"
      puts "  body: #{entry.body[0..100]}..."

      puts
      puts '~' * 100
    end
  end
end
