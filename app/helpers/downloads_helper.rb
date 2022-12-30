# frozen_string_literal: true

# Helper functions relating to downloads and downloadability.
module DownloadsHelper
  # Can the target be downloaded, i.e. is it posted and visible to all
  # registered users?
  def downloadable?(target)
    return false unless target.respond_to?(:posted?) && target.respond_to?(:hidden_by_admin)
    return target.posted? && !target.hidden_by_admin if target.is_a?(Series)

    target.posted? && !target.hidden_by_admin && !target.in_unrevealed_collection
  end

  # Obtains the download URL for something that can be downloaded
  # (currently series and works).
  def download_url_for(downloadable, format)
    path = Download.new(downloadable, format: format).public_path
    url_for("#{path}?updated_at=#{downloadable.updated_at.to_i}").gsub(" ", "%20")
  end
end
