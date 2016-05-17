module Plotline
  module Import
    class UnsupportedFileType; end

    class Runner
      HANDLERS = [
        Plotline::Import::Handlers::MarkdownFile,
        Plotline::Import::Handlers::ImageFile
      ].freeze

      attr_reader :source_dir, :target_dir, :public_dir, :uploads_dir

      def initialize(source_dir, target_dir)
        @source_dir = source_dir
        @target_dir = target_dir
        @public_dir = target_dir + '/public'
        @uploads_dir = target_dir + '/public/uploads'

        @handlers = HANDLERS.map { |klass| klass.new(self) }
      end

      def import_all!
        process_files(Dir[@source_dir + '/**/*'])
      end

      def process_files(files)
        files.each do |filename|
          next if FileTest.directory?(filename)

          handler_found = false
          @handlers.each do |handler|
            if handler.supported_file?(filename)
              handler.import(filename)
              handler_found = true
            end
          end

          raise UnsupportedFileType unless handler_found
        end
      end
    end
  end
end
