class TranslationNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :locale

end
