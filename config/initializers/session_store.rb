class ActionDispatch::Session::ForceSignedCookieStore < ActionDispatch::Session::CookieStore
  private

  # Override the cookie_jar method to use signed cookies
  # regardless of whether a secret_key_base has been set
  def cookie_jar(request)
    request.cookie_jar.signed
  end
end

# Be sure to restart your server when you modify this file.

Otwarchive::Application.config.session_store :force_signed_cookie_store, key: '_otwarchive_session', expire_after: ArchiveConfig.DEFAULT_SESSION_LENGTH_IN_WEEKS.weeks

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Otwarchive::Application.config.session_store :active_record_store
