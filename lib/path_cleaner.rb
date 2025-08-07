module PathCleaner
  def relative_path(uri)
    parsed = URI.parse(uri)
    return uri if parsed.scheme.nil? && parsed.host.nil? && uri.start_with?("/") && !uri.start_with?("//")
  rescue URI::InvalidURIError
    nil
  end
end
