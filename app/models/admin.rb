class Admin < ActiveRecord::Base
  # Authlogic gem
  acts_as_authentic do |config|
    config.transition_from_restful_authentication = true
    if (ArchiveConfig.BCRYPT  || "true")  == "true" then
      puts "Using BCrypt ************************************************************************"
      config.crypto_provider = Authlogic::CryptoProviders::BCrypt
      config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512, Authlogic::CryptoProviders::Sha1]
    else
      puts "Using SHA1 ************************************************************************"
      config.crypto_provider = Authlogic::CryptoProviders::Sha512
      config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha1]
    end
  end
  
  has_many :log_items
  has_many :invitations, :as => :creator
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler 
end
