class WorkUrl < ApplicationRecord
  belongs_to :work

  VARIANTS = %w[original minimal no_www with_www encoded decoded minimal_no_protocol_no_www].freeze

  def self.build_url_attributes(url)
    url = UrlFormatter.new(url)

    VARIANTS.to_h { |s| [s.to_sym, url.send(s)] }
  end

  def self.prepare(work, url)
    work_url = WorkUrl.find_or_initialize_by(work_id: work.id)

    work_url.assign_attributes(self.build_url_attributes(url))

    work.work_url = work_url

    work_url
  end

  def self.find_by_url_generation_key
    "/v1/find_by_url_generation_key"
  end

  def self.find_by_url_generation
    Rails.cache.fetch(WorkUrl.find_by_url_generation_key, raw: true) { rand(1..1000) }
  end

  def self.flush_find_by_url_cache
    Rails.cache.increment(WorkUrl.find_by_url_generation_key)
  end

  def self.find_by_url_cache_key(url)
    url = UrlFormatter.new(url)
    "/v1/find_by_url/#{WorkUrl.find_by_url_generation}/#{url.encoded}"
  end

  # Match `url` to a work's imported_from_url field using progressively fuzzier matching:
  # 1. first exact match
  # 2. first exact match with variants of the provided url
  # 3. first match on variants of both the imported_from_url and the provided url if there is a partial match

  def self.find_by_url_uncached(url)
    url = UrlFormatter.new(url)

    WorkUrl.where(
      VARIANTS.map { |column| "#{column} = ?" }
        .join(" OR "),
      *VARIANTS.map { |method| url.send(method) }
    ).first&.work ||
      # TODO: AO3-6979
      Work.where(imported_from_url: url.original).first ||
      Work.where(imported_from_url: [url.minimal,
                                     url.with_http, url.with_https,
                                     url.no_www, url.with_www,
                                     url.encoded, url.decoded,
                                     url.minimal_no_protocol_no_www]).first ||
      Work.where("imported_from_url LIKE ? or imported_from_url LIKE ?",
                 "http://#{url.minimal_no_protocol_no_www}%",
                 "https://#{url.minimal_no_protocol_no_www}%").select do |w|
        work_url = UrlFormatter.new(w.imported_from_url)
        %w[original minimal no_www with_www with_http with_https encoded decoded].any? do |method|
          work_url.send(method) == url.send(method)
        end
      end.first
  end

  def self.find_by_url(url)
    Rails.cache.fetch(WorkUrl.find_by_url_cache_key(url)) do
      find_by_url_uncached(url)
    end
  end
end
