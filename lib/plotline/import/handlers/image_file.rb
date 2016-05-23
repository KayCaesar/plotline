module Plotline
  module Import
    module Handlers
      class ImageFile < Base
        IMAGE_EXTENSIONS = %w(jpg jpeg png gif bmp tiff).freeze

        def supported_file?(filename)
          IMAGE_EXTENSIONS.include?(File.extname(filename).gsub('.', ''))
        end

        def import(filename)
          log "\e[34mImporting:\e[0m #{filename}"

          if !File.exists?(filename)
            log "FILE REMOVED"
            return
          end

          dst = filename.gsub(@runner.source_dir, @runner.uploads_dir)

          FileUtils.mkdir_p(File.dirname(dst))
          FileUtils.cp(filename, dst)

          file = dst.gsub(@runner.public_dir, '')
          image = Plotline::Image.find_or_initialize_by(image: file)
          return if image.persisted? && File.size(dst) == image.file_size

          image.save!
        end
      end
    end
  end
end
