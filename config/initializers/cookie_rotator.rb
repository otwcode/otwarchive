# frozen_string_literal: true

# To support a rolling deploy of SHA256 cookies:
# 1. Done: Read SHA256 cookies, but write back SHA1 cookies (writing is based on current setting of config.active_support.key_generator_hash_digest_class).
# 2. Current: Switch this rotator to read SHA1 and change key_generator_hash_digest_class to write SHA256.
#   Explanation:
#     During rolling deploy, rotator from step 1 will still be present on some servers. It will read the new SHA256 cookies and write cookies as SHA1.
#     While new rotator from step 2 on updated servers converts old SHA1 cookies to new SHA256 cookies.
#     After rolling deploy is finished, only new rotator will be present on all servers and will convert all SHA1 cookies to SHA256.
# 3. Next: After the rotator from step 2 has been deployed for a while and all cookies should be converted to SHA256, remove the rotator.
# Ref: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#key-generator-digest-class-change-requires-a-cookie-rotator
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
