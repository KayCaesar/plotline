module Plotline
  class EntryPresenter < BasePresenter
    presents :entry

    def body_markdown
      text = parse_custom_markdown(@object.body.to_s)
      RDiscount.new(text, :smart, :footnotes).to_html.html_safe
    end

    def photoset_item(src:, alt:, attrs:)
      img = images_hash[src]
      attrs["class"] = "photoset-item " + attrs["class"].to_s

      photoset_item_html(img, src, alt, attrs, image_attrs(img))
    end

    def photoset_item_html(img, src, alt, attrs, image_attrs)
      content_tag(:figure, attrs) do
        concat image_tag(src, { alt: alt }.merge(image_attrs))
        concat content_tag(:figcaption, alt)
      end
    end

    def single_image_html(src:, alt:, attrs:)
      content_tag(:figure, attrs) do
        concat image_tag(src, alt: alt)
        concat content_tag(:figcaption, alt)
      end
    end

    def image_attrs(img)
      return { data: {} } unless img

      { data: { width: img.width, height: img.height, ratio: img.ratio } }
    end

    private

    def parse_custom_markdown(text)
      Plotline::CustomMarkdownParser.new(self).parse(text)
    end

    def images_hash
      @images_hash ||= Plotline::Image.all.each_with_object({}) do |img, hash|
        Rails.logger.warn(img.image)
        hash['/media/' + img.image] = img
      end
    end
  end
end
