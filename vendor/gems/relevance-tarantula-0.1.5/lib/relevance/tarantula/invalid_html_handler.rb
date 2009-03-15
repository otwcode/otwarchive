class Relevance::Tarantula::InvalidHtmlHandler
  include Relevance::Tarantula
  def handle(result)
    response = result.response
    return unless response.html?
    begin
      body = HTML::Document.new(response.body, true)
    rescue Exception => e
      error_result = result.dup
      error_result.success = false
      error_result.description = "Bad HTML (Scanner)"
      error_result.data = e.message
      error_result
    else
      nil
    end
  end
end
