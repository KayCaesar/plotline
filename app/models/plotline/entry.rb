module Plotline
  class Entry < ActiveRecord::Base
    include Plotline::Concerns::Searchable
    include Plotline::Concerns::Taggable
    include Plotline::Concerns::Family

    enum status: [ :draft, :published ]

    belongs_to :user

    scope :drafts, -> { where(status: :draft) }
    scope :published, -> { where(status: :published).where('published_at <= ?', Time.zone.now) }

    validates :title, presence: true
    validates :slug, uniqueness: { scope: :type, allow_blank: true }

    def self.content_attr(attr_name, attr_type = :string)
      content_attributes[attr_name] = attr_type

      define_method(attr_name) do
        self.payload ||= {}
        self.payload[attr_name.to_s]
      end

      define_method("#{attr_name}=".to_sym) do |value|
        self.payload ||= {}
        self.payload[attr_name.to_s] = value
      end
    end

    def self.content_attributes
      @content_attributes ||= {}
    end
  end
end
