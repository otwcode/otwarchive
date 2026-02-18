class ArchiveFaq < ApplicationRecord
  FAQ_MENU_CACHE_KEY = "v1/archive_faqs/faq_menu".freeze

  acts_as_list
  translates :title
  translation_class.include(Globalized)

  has_many :questions, -> { order(:position) }, dependent: :destroy, inverse_of: :archive_faq
  accepts_nested_attributes_for :questions, allow_destroy: true

  validates :slug, presence: true, uniqueness: true
  validate :faq_menu_selection_limit_not_exceeded

  belongs_to :language

  before_validation :set_slug
  before_validation :set_faq_menu_position
  after_commit :expire_faq_menu_cache
  after_commit :compact_faq_menu_positions, if: :saved_change_to_include_in_faq_menu?

  def set_slug
    return unless I18n.locale == :en

    self.slug = title.parameterize
  end

  # Change the positions of the questions in the archive_faq
  def reorder_list(positions)
    SortableList.new(self.questions.in_order).reorder_list(positions)
  end

  def to_param
    slug_was
  end

  def faq_menu_name
    faq_menu_display_name.presence || title
  end

  def self.faq_menu_selection_limit
    ArchiveConfig.FAQ_MENU_SELECTION_LIMIT.to_i
  end

  def self.faq_menu_items(locale = I18n.locale)
    locale = locale.to_s
    Rails.cache.fetch("#{FAQ_MENU_CACHE_KEY}/#{locale}") do
      I18n.with_locale(locale) do
        in_faq_menu_order.limit(faq_menu_selection_limit).map do |faq|
          { slug: faq.slug, menu_name: faq.faq_menu_name }
        end
      end
    end
  end

  def self.in_faq_menu_order
    where(include_in_faq_menu: true).order(:faq_menu_position, :position, :id)
  end

  def self.reorder_list(positions)
    SortableList.new(self.order("position ASC")).reorder_list(positions)
  end

  def self.expire_faq_menu_cache
    I18n.available_locales.each do |locale|
      Rails.cache.delete("#{FAQ_MENU_CACHE_KEY}/#{locale}")
    end
  end

  def self.compact_faq_menu_positions!
    in_faq_menu_order.each_with_index do |faq, index|
      next if faq.faq_menu_position == index + 1

      where(id: faq.id).update_all(faq_menu_position: index + 1)
    end
  end

  def move_in_faq_menu!(direction)
    return unless include_in_faq_menu?

    self.class.compact_faq_menu_positions!
    faqs = self.class.in_faq_menu_order.to_a
    current_index = faqs.index { |faq| faq.id == id }
    return if current_index.nil?

    target_index = direction == "up" ? current_index - 1 : current_index + 1
    return if target_index.negative? || target_index >= faqs.length

    current_faq = faqs[current_index]
    target_faq = faqs[target_index]
    self.class.transaction do
      self.class.where(id: current_faq.id).update_all(faq_menu_position: target_faq.faq_menu_position)
      self.class.where(id: target_faq.id).update_all(faq_menu_position: current_faq.faq_menu_position)
    end
    self.class.expire_faq_menu_cache
  end

  private

  def faq_menu_selection_limit_not_exceeded
    return unless include_in_faq_menu?

    already_selected_count = self.class.where(include_in_faq_menu: true).where.not(id: id).count
    return unless already_selected_count >= self.class.faq_menu_selection_limit

    errors.add(:include_in_faq_menu, :too_many_selected, count: self.class.faq_menu_selection_limit)
  end

  def expire_faq_menu_cache
    self.class.expire_faq_menu_cache
  end

  def set_faq_menu_position
    if include_in_faq_menu?
      self.faq_menu_position ||= self.class.where(include_in_faq_menu: true).maximum(:faq_menu_position).to_i + 1
    else
      self.faq_menu_position = nil
    end
  end

  def compact_faq_menu_positions
    self.class.compact_faq_menu_positions!
  end
end
