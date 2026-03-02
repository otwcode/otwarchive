# Fix issues where older browsers generate millions of audits.
# https://github.com/heartcombo/devise/issues/4584

module FixDevise
  def authenticate!
    super
    env["devise.skip_trackable"] = true if self.valid?
  end
end

Devise::Strategies::DatabaseAuthenticatable.prepend FixDevise
