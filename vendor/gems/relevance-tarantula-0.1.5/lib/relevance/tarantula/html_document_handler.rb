require 'hpricot'

class Relevance::Tarantula::HtmlDocumentHandler 
  extend Forwardable
  def_delegators("@crawler", :queue_link, :queue_form)
  
  def initialize(crawler)
    @crawler = crawler
  end              
  # HTML::Document shouts to stderr when it sees ugly HTML
  # We don't want this -- the InvalidHtmlHandler will deal with it
  def html_doc_without_stderr_noise(html)  
    body = nil
    Recording.stderr do
      body = Hpricot html
    end       
    body
  end
  def handle(result)
    response = result.response
    url = result.url
    return unless response.html?
    body = html_doc_without_stderr_noise(response.body)
    body.search('a').each do |tag|
      queue_link(tag, url)
    end
    body.search('link').each do |tag|
      queue_link(tag, url)
    end
    body.search('form').each do |form|
      form['action'] = url unless form['action']
      queue_form(form, url)
    end
    nil
  end
end
