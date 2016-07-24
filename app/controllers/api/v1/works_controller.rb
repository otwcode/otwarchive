class Api::V1::WorksController < Api::V1::BaseController
  respond_to :json

  # Return the URLs of a batch of individual works. Limits the number of URLs to
  # IMPORT_MAX_CHAPTERS so it doesn't get tied up in checking URLs for too long.
  # Params:
  # +original_urls+:: an array of original URLs to find on the Archive
  def batch_urls
    original_urls = params[:original_urls]
    status = :bad_request
    results = []
    if original_urls.nil? || original_urls.blank? || original_urls.size == 0
      results << { error: "Please provide a list of URLs to find." }
    elsif original_urls.size >= ArchiveConfig.IMPORT_MAX_CHAPTERS
      results << { error: "Please provide no more than #{ ArchiveConfig.IMPORT_MAX_CHAPTERS } URLs to find." }
    else
      status = :ok
      results = process_batch_url(original_urls)
    end
    render status: status, json: results
  end

  private

  def process_batch_url(original_urls)
    results = []
    original_urls.each do |original_url|
      work_result = work_url_from_external(original_url)
      if work_result[:work].nil?
        results << { status: :not_found,
                     original_url: original_url,
                     error: work_result[:error] }
      else
        work = work_result[:work]
        results << { status: :ok,
                     original_url: original_url,
                     work_url: work_url(work),
                     created: work.created_at }
      end
    end
    results
  end

  def work_url_from_external(original_url)
    work = nil
    if original_url.blank?
      error = "Please provide the original URL for the work."
    else
      work = Work.where(imported_from_url: original_url).first
      if !work
        error = "No work has been imported from \"" + original_url + "\"."
      end
    end
    {
      original_url: original_url,
      work: work,
      error: error
    }
  end

end
