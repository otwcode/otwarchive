class ApiKey < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :access_token, presence: true, uniqueness: { case_sensitive: false }

  before_validation(on: :create) do
    self.access_token = SecureRandom.hex
  end
end
