module Plotline
  class Image < ActiveRecord::Base
    before_save :set_metadata

    private

    def set_metadata
      File.open('./public/media/' + image) do |file|
        img = ::MiniMagick::Image.open(file)

        self.width, self.height = img[:dimensions]
        self.ratio = self.width.to_f / self.height.to_f
        self.exif = img.exif

        self.content_type = img.mime_type
        self.file_size    = file.size
      end
    end
  end
end
