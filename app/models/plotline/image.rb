module Plotline
  class Image < ActiveRecord::Base
    before_save :set_metadata
    after_destroy :remove_image_file

    def filename
      File.join('./public', image)
    end

    def remove_image_file
      File.delete(filename)
    end

    private

    def set_metadata
      File.open(filename) do |file|
        img = FastImage.new(file)

        self.width, self.height = img.size
        self.ratio = self.width.to_f / self.height.to_f

        self.content_type = img.type
        self.file_size    = file.size
      end

      self.exif = Exiftool.new(filename).to_hash
    end
  end
end
