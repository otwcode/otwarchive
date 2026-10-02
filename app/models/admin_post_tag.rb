class AdminPostTag < ApplicationRecord
  include AsyncWithResque
  @queue = :utilities

  belongs_to :language
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

  def self.delete_unused
    left_outer_joins(:admin_post_taggings).where(admin_post_taggings: { id: nil }).delete_all
  end
end
