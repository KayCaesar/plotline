module Plotline
  module Import
    module Handlers
      class VideoFile < Base
        IMAGE_EXTENSIONS = %w(mov mp4 avi wmv).freeze

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
        end
      end
    end
  end
end
