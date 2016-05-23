module Plotline
  class Image < ActiveRecord::Base
    before_save :set_metadata
    after_destroy :remove_image_file

    def filename
      remote_file? ? image : File.join('./public', image)
    end

    def remove_image_file
      File.delete(filename) unless remote_file?
    end

    private

    def set_metadata
      img = FastImage.new(filename)

      self.width, self.height = img.size
      self.ratio = self.width.to_f / self.height.to_f
      self.content_type = img.type
      self.file_size = img.content_length

      return if remote_file?

      File.open(filename) do |file|
        self.file_size = file.size # content_length doesn't always work
      end

      self.exif = Exiftool.new(filename).to_hash
    end

    def remote_file?
      image.start_with?('http')
    end
  end
end
