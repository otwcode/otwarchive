class AkismetClient
  include HTTParty
  base_uri "https://rest.akismet.com"
  headers "User-Agent": "#{ArchiveConfig.APP_SHORT_NAME}/#{ArchiveConfig.REVISION}",
          "Content-Type" => "application/x-www-form-urlencoded"

  SUBMISSION_RESPONSE = "Thanks for making the web a better place.".freeze

  def self.valid_key?(key, blog)
    key.present? && blog.present? && self.post("/1.1/verify-key", body: URI.encode_www_form(key: key, blog: blog)).body == "valid"
  end

  def self.spam?(attributes)
    return false unless self.enabled?

    response = self.post("/1.1/comment-check", body: encode_body(attributes))
    response.headers["X-akismet-pro-tip"] == "discard" ? "discard" : response.body == "true"
  end

  def self.submit_spam(attributes)
    return true unless self.enabled?

    self.post("/1.1/submit-spam", body: encode_body(attributes)).body == SUBMISSION_RESPONSE
  end

  def self.submit_ham(attributes)
    return true unless self.enabled?

    self.post("/1.1/submit-ham", body: encode_body(attributes)).body == SUBMISSION_RESPONSE
  end

  def self.enabled?
    ArchiveConfig.AKISMET_KEY.present? && ArchiveConfig.AKISMET_NAME.present?
  end

  def self.encode_body(body = {})
    # disable learning from tests
    body = body.merge(is_test: true) if Rails.env.test?

    URI.encode_www_form(body)
  end

  private_class_method :encode_body
end
