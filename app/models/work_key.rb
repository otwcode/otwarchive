class WorkKey < ActiveRecord::Base
  belongs_to :work
  belongs_to :user

  def generate_key
    SecureRandom.base64(13)
  end
end