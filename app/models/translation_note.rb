class TranslationNote < ApplicationRecord
  belongs_to :user
  belongs_to :locale

end
