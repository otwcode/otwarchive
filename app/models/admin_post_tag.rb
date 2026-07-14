class AdminPostTag < ApplicationRecord
  belongs_to :locale_language, foreign_key: :language_id, inverse_of: :admin_post_tags
  has_many :admin_post_taggings
  has_many :admin_posts, through: :admin_post_taggings

  validates_presence_of :name
  validates :name, uniqueness: true
  validates_format_of :name, with: /[a-zA-Z0-9-]+$/, multiline: true

  # Find or create by name, and set the language if it's a new record
  def self.fetch(name, language_id)
    return if name.blank?

    tag = self.find_by_name(name)
    return tag unless tag.nil?

    tag = AdminPostTag.new(name: name, language_id: language_id)
    tag.valid? ? tag : nil
  end

end
