module Plotline
  class Importer
    FILENAME_SPLIT_PATTERN = /^(\d{4}-\d{2}-\d{2})-(.*)/
    FRONT_MATTER_PATTERN = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

    def initialize(source_dir, target_dir)
      @source_dir = source_dir
      @target_dir = target_dir
      @public_dir = target_dir + '/public'
      @uploads_dir = target_dir + '/public/media'
    end

    def import_file(filename)
      puts '~' * 80
      puts "\n\e[34mImporting:\e[0m #{filename}"

      date, slug = filename_to_date_and_slug(filename)

      if !File.exists?(filename) && entry = Plotline::Entry.find_by(slug: slug)
        puts "  \e[31mFile removed, deleting entry\e[0m \e[32m##{entry.id}\e[0m"
        entry.destroy
        return
      end

      contents = File.read(filename)
      contents = convert_relative_image_paths(filename, contents)
      checksum = Digest::MD5.hexdigest(contents)

      meta, contents = extract_metadata_from_contents(contents)

      if meta['type'].blank?
        raise "\e[31mMissing 'type' attribute in #{filename}\e[0m"
      end

      klass = meta.delete('type').classify.constantize
      entry = klass.find_or_initialize_by(slug: slug)

      if entry.checksum == checksum
        puts "File unchanged, skipping.\n\n"
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
      Dir[@uploads_dir + '/**/*.{jpg,jpeg,png,gif,bmp,tiff}'].each do |img|
        filename = img.gsub(@public_dir, '')

        image = Plotline::Image.find_or_initialize_by(image: filename)
        next if image.persisted? && File.size(img) == image.file_size

        image.save!
      end
    end

    private

    # Turns markdown filename to date and slug, e.g.:
    #   2016-03-20_hello-world.md
    # results in:
    #   ['2016-03-20', 'hello-world']
    #
    # If there's no date in the filename (e.g. when file is a draft),
    # only slug will be returned and date will be nil.
    def filename_to_date_and_slug(filename)
      date, slug = File.basename(filename, ".*").split(FILENAME_SPLIT_PATTERN).reject { |m| m.blank? }
      if slug.blank?
        slug = date
        date = nil
      end

      [date, slug]
    end

    def extract_metadata_from_contents(contents)
      if result = contents.match(FRONT_MATTER_PATTERN)
        contents = contents[(result[0].length)...(contents.length)]
        meta = YAML.safe_load(result[0])
      else
        meta = {}
      end

      [meta, contents]
    end

    # Converts relative image paths found in markdown files
    # to the target path in app/public
    def convert_relative_image_paths(filename, contents)
      entry_file_dir = File.dirname(filename)

      contents.gsub(/(\.\.\/.+\.(jpg|jpeg|gif|png|bmp))/) do
        absolute_path = File.expand_path(File.join(entry_file_dir, $1))
        absolute_path.gsub(@source_dir, '')
      end
    end

    def dump_log(entry, meta)
      puts "\n\e[32mMetadata:\e[0m"
      meta.each do |k, v|
        puts "  \e[32m#{k}:\e[0m #{v}"
      end

      puts "\n\e[32m#{entry.class.name}:\e[0m"
      puts "  \e[32mtitle:\e[0m #{entry.title}"
      puts "  \e[32mslug:\e[0m #{entry.slug}"
      puts "  \e[32mdraft:\e[0m #{entry.draft?}"
      puts "  \e[32mpublished_at:\e[0m #{entry.published_at}"
      puts "  \e[32mbody:\e[0m #{entry.body[0..100].gsub("\n", " ")}..."
      puts
    end
  end
end
