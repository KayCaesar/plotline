module Plotline
  module Import
    module Handlers
      class MarkdownFile < Base
        FILENAME_SPLIT_PATTERN = /^(\d{4}-\d{2}-\d{2})-(.*)/
        FRONT_MATTER_PATTERN = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
        MARKDOWN_EXTENSIONS = %(md markdown).freeze

        def supported_file?(filename)
          MARKDOWN_EXTENSIONS.include?(File.extname(filename).gsub('.', ''))
        end

        def import(filename)
          log "\e[34mImporting:\e[0m #{filename}"

          date, slug = filename_to_date_and_slug(filename)

          if !File.exists?(filename) && entry = Plotline::Entry.find_by(slug: slug)
            log "  \e[31mFile removed, deleting entry\e[0m \e[32m##{entry.id}\e[0m"
            entry.destroy
            return
          end

          full_contents = File.read(filename)
          full_contents = convert_relative_image_paths(filename, full_contents)

          meta, contents = extract_metadata_from_contents(full_contents)

          if meta['type'].blank?
            raise "\e[31mMissing 'type' attribute in #{filename}\e[0m"
          end

          klass = meta.delete('type').classify.constantize
          entry = klass.find_or_initialize_by(slug: slug)

          process_image_urls(full_contents)
          update_entry(entry, meta, date, contents, full_contents)
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

          contents.gsub(/(\.\.\/.+\.(?:jpe?g|gif|png))/) do
            absolute_path = File.expand_path(File.join(entry_file_dir, $1))
            '/uploads' + absolute_path.gsub(@runner.source_dir, '')
          end
        end

        def process_image_urls(contents)
          URI.extract(contents).select{ |url| url[/\.(?:jpe?g|png|gif)\b/i] }.each do |url|
            Plotline::Image.find_or_create_by(image: url)
          end
        end

        def update_entry(entry, meta, date, contents, full_contents)
          checksum = Digest::MD5.hexdigest(full_contents)
          if entry.checksum == checksum
            log "  File unchanged, skipping."
            return
          end

          draft = !!meta.delete('draft')
          entry.status = draft ? :draft : :published

          entry.assign_attributes(meta.merge(
            body: contents,
            checksum: checksum,
            published_at: (Date.parse(date) if date && !draft)
          ))

          dump_log(entry, meta)

          entry.save!
        end

        def dump_log(entry, meta)
          log "\e[32mMetadata:\e[0m"
          meta.each do |k, v|
            log "  \e[32m#{k}:\e[0m #{v}"
          end

          log "\e[32m#{entry.class.name}:\e[0m"
          log "  \e[32mtitle:\e[0m #{entry.title}"
          log "  \e[32mslug:\e[0m #{entry.slug}"
          log "  \e[32mdraft:\e[0m #{entry.draft?}"
          log "  \e[32mpublished_at:\e[0m #{entry.published_at}"
          log "  \e[32mbody:\e[0m #{entry.body[0..100].gsub("\n", " ")}..."
        end
      end
    end
  end
end
