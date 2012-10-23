class Locale < ActiveRecord::Base
  belongs_to :language
  has_many :translations
  has_many :translation_notes
  validates_presence_of :iso
  validates_uniqueness_of :iso
  validates_presence_of :name

  def to_param
    iso
  end

end
