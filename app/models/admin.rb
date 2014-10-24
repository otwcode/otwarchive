class Admin < ActiveRecord::Base
  # Authlogic gem
  acts_as_authentic do |config|
    config.transition_from_restful_authentication = true
    if (ArchiveConfig.BCRYPT  || "true")  == "true" then
      config.crypto_provider = Authlogic::CryptoProviders::BCrypt
      config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512, Authlogic::CryptoProviders::Sha1]
    else
      config.crypto_provider = Authlogic::CryptoProviders::Sha512
      config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha1]
    end
  end
  
  has_many :log_items
  has_many :invitations, :as => :creator
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler 
end
