# frozen_string_literal: true

# Due to the rolled back deploy, some users have SHA256 cookies.
# Read them, but write back SHA1 cookies (writing is based on current setting of config.active_support.key_generator_hash_digest_class)
# Ref: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#key-generator-digest-class-change-requires-a-cookie-rotator
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA256
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
