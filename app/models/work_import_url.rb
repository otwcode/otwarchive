class WorkImportUrl < ApplicationRecord
  belongs_to :work

  validates :url, presence: true
  validates :work_id, uniqueness: true

  before_validation :compute_variants

  # Cache key management
  FIND_BY_URL_GENERATION_KEY = "/v1/work_import_url/find_by_url_generation_key"

  def self.find_by_url_generation
    Rails.cache.fetch(FIND_BY_URL_GENERATION_KEY, raw: true) { rand(1..1000) }
  end

  def self.flush_find_by_url_cache
    Rails.cache.increment(FIND_BY_URL_GENERATION_KEY)
  end

  def self.find_by_url_cache_key(url)
    formatted = UrlFormatter.new(url)
    "/v2/work_import_url/find_by_url/#{find_by_url_generation}/#{formatted.encoded}"
  end

  # Find the work associated with the given URL, using cached lookups.
  def self.find_work_by_url(url)
    Rails.cache.fetch(find_by_url_cache_key(url)) do
      find_work_by_url_uncached(url)
    end
  end

  # Find the work associated with the given URL using exact-match lookups
  # against pre-computed URL variants. No LIKE queries needed.
  #
  # Matching strategy:
  # 1. Exact match on original URL
  # 2. Exact match on minimal form (strips query params except sid)
  # 3. Exact match on minimal_no_protocol_no_www (covers http/https + www variants)
  def self.find_work_by_url_uncached(url)
    formatted = UrlFormatter.new(url)

    record =
      find_by(url: formatted.original) ||
      find_by(minimal: formatted.minimal) ||
      find_by(minimal_no_protocol_no_www: formatted.minimal_no_protocol_no_www)

    record&.work
  end

  private

  def compute_variants
    return if url.blank?

    formatted = UrlFormatter.new(url)
    self.minimal = formatted.minimal
    self.minimal_no_protocol_no_www = formatted.minimal_no_protocol_no_www
  end
end
