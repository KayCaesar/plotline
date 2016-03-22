module Plotline
  class Image < ActiveRecord::Base
    before_save :set_metadata
    after_destroy :remove_image_file

    private

    def set_metadata
      filename = File.join('./public', image)
      File.open(filename) do |file|
        img = FastImage.new(file)

        self.width, self.height = img.size
        self.ratio = self.width.to_f / self.height.to_f

        self.content_type = img.type
        self.file_size    = file.size
      end

      self.exif = Exiftool.new(filename).to_hash
    end

    def remove_image_file
      File.delete(File.join('./public', image))
    end
  end
end
