class ExternalAuthorName < ActiveRecord::Base
  NAME_LENGTH_MIN = 1
  NAME_LENGTH_MAX = 100

  belongs_to :external_author
  
  validates_presence_of :name

  validates_length_of :name, 
    :within => NAME_LENGTH_MIN..NAME_LENGTH_MAX, 
    :too_short => t('name_too_short', :default => "is too short (minimum is {{min}} characters)", :min => NAME_LENGTH_MIN),
    :too_long => t('name_too_long', :default => "is too long (maximum is {{max}} characters)", :max => NAME_LENGTH_MAX)

  validates_uniqueness_of :name, :scope => :external_author_id, :case_sensitive => false  

  validates_format_of :name, 
    :message => t('name_invalid_characters', :default => 'can contain letters, numbers, spaces, underscores, and dashes.'),
    :with => /\A[\w -]*\Z/    

  validates_format_of :name, 
    :message => t('name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/

  
end
