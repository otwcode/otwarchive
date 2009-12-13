class Gift < ActiveRecord::Base
  NAME_LENGTH_MAX = 100

  belongs_to :work
  
  validates_presence_of :recipient_name

  validates_length_of :recipient_name,
    :maximum => NAME_LENGTH_MAX,
    :too_long => t('gift.recipient_name_too_long', :default => "must be less than {{max}} characters long.", :max => NAME_LENGTH_MAX)

  validates_format_of :recipient_name, 
    :message => t('gift.name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/

end
