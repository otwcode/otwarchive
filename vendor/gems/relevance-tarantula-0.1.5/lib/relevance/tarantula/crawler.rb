require File.expand_path(File.join(File.dirname(__FILE__), "rails_integration_proxy"))
require File.expand_path(File.join(File.dirname(__FILE__), "html_document_handler.rb"))

class Relevance::Tarantula::Crawler
  extend Forwardable
  include Relevance::Tarantula

  attr_accessor :proxy, :handlers, :skip_uri_patterns, :log_grabber,
                :reporters, :links_to_crawl, :links_queued, :forms_to_crawl,
                :form_signatures_queued, :max_url_length, :response_code_handler,
                :times_to_crawl, :fuzzers, :test_name
  attr_reader   :transform_url_patterns, :referrers, :failures, :successes

  def initialize
    @max_url_length = 1024
    @successes = []
    @failures = []
    @handlers = [@response_code_handler = Result]
    @links_queued = Set.new
    @form_signatures_queued = Set.new
    @links_to_crawl = []
    @forms_to_crawl = []
    @referrers = {}
    @skip_uri_patterns = [
      /^javascript/,
      /^mailto/,
      /^http/,
    ]
    self.transform_url_patterns = [
      [/#.*$/, '']
    ]
    @reporters = [Relevance::Tarantula::IOReporter.new($stderr)]
    @decoder = HTMLEntities.new
    @times_to_crawl = 1
    @fuzzers = [Relevance::Tarantula::FormSubmission]
  end

  def method_missing(meth, *args)
    super unless Result::ALLOW_NNN_FOR =~ meth.to_s
    @response_code_handler.send(meth, *args)
  end

  def transform_url_patterns=(patterns)
    @transform_url_patterns = patterns.map do |pattern|
      Array === pattern ? Relevance::Tarantula::Transform.new(*pattern) : pattern
    end
  end

  def crawl(url = "/")
    orig_links_queued = @links_queued.dup
    orig_form_signatures_queued = @form_signatures_queued.dup
    orig_links_to_crawl = @links_to_crawl.dup
    orig_forms_to_crawl = @forms_to_crawl.dup
    @times_to_crawl.times do |i|
      queue_link url
      do_crawl

      puts "#{(i+1).ordinalize} crawl" if @times_to_crawl > 1

      if i + 1 < @times_to_crawl
        @links_queued = orig_links_queued
        @form_signatures_queued = orig_form_signatures_queued
        @links_to_crawl = orig_links_to_crawl
        @forms_to_crawl = orig_forms_to_crawl
        @referrers = {}
      end
    end
  rescue Interrupt
    $stderr.puts "CTRL-C"
  ensure
    report_results
  end

  def finished?
    @links_to_crawl.empty? && @forms_to_crawl.empty?
  end

  def do_crawl
    while (!finished?)
      crawl_queued_links
      crawl_queued_forms
    end
  end

  def crawl_queued_links
    while (link = @links_to_crawl.pop)
      response = proxy.send(link.method, link.href)
      log "Response #{response.code} for #{link}"
      handle_link_results(link, response)
      blip
    end
  end

  def save_result(result)
    reporters.each do |reporter|
      reporter.report(result)
    end
  end

  def handle_link_results(link, response)
    handlers.each do |h|
      begin
        save_result h.handle(Result.new(:method => link.method,
                                       :url => link.href,
                                       :response => response,
                                       :log => grab_log!,
                                       :referrer => referrers[link],
                                       :test_name => test_name).freeze)
      rescue Exception => e
        log "error handling #{link} #{e.message}"
        # TODO: pass to results
      end
    end
  end

  def crawl_form(form)
    response = proxy.send(form.method, form.action, form.data)
    log "Response #{response.code} for #{form}"
    response
  rescue ActiveRecord::RecordNotFound => e
    log "Skipping #{form.action}, presumed ok that record is missing"
    Relevance::Tarantula::Response.new(:code => "404", :body => e.message, :content_type => "text/plain")
  end

  def crawl_queued_forms
    while (form = @forms_to_crawl.pop)
      response = crawl_form(form)
      handle_form_results(form, response)
      blip
    end
  end

  def grab_log!
    @log_grabber && @log_grabber.grab!
  end

  def handle_form_results(form, response)
    handlers.each do |h|
      save_result h.handle(Result.new(:method => form.method,
                                     :url => form.action,
                                     :response => response,
                                     :log => grab_log!,
                                     :referrer => form.action,
                                     :data => form.data.inspect,
                                     :test_name => test_name).freeze)
    end
  end

  def should_skip_url?(url)
    return true if url.blank?
    if @skip_uri_patterns.any? {|pattern| pattern =~ url}
      log "Skipping #{url}"
      return true
    end
    if url.length > max_url_length
      log "Skipping long url #{url}"
      return true
    end
  end

  def should_skip_link?(link)
    should_skip_url?(link.href) || @links_queued.member?(link)
  end

  def should_skip_form_submission?(fs)
    should_skip_url?(fs.action) || @form_signatures_queued.member?(fs.signature)
  end

  def transform_url(url)
    return unless url
    url = @decoder.decode(url)
    @transform_url_patterns.each do |pattern|
      url = pattern[url]
    end
    url
  end

  def queue_link(dest, referrer = nil)
    dest = Link.new(dest)
    dest.href = transform_url(dest.href)
    return if should_skip_link?(dest)
    @referrers[dest] = referrer if referrer
    @links_to_crawl << dest
    @links_queued << dest
    dest
  end

  def queue_form(form, referrer = nil)
    fuzzers.each do |fuzzer|
      fuzzer.mutate(Form.new(form)).each do |fs|
        # fs = fuzzer.new(Form.new(form))
        fs.action = transform_url(fs.action)
        return if should_skip_form_submission?(fs)
        @referrers[fs.action] = referrer if referrer
        @forms_to_crawl << fs
        @form_signatures_queued << fs.signature
      end
    end
  end

  def report_dir
    File.join(rails_root, "tmp", "tarantula")
  end

  def generate_reports
    errors = []
    reporters.each do |reporter|
      begin
        reporter.finish_report(test_name)
      rescue RuntimeError => e
        errors << e
      end
    end
    unless errors.empty?
      raise errors.map(&:message).join("\n")
    end
  end

  def report_results
    generate_reports
  end

  def total_links_count
    @links_queued.size + @form_signatures_queued.size
  end

  def links_remaining_count
    @links_to_crawl.size + @forms_to_crawl.size
  end

  def links_completed_count
      total_links_count - links_remaining_count
  end

  def blip
    unless verbose
      print "\r #{links_completed_count} of #{total_links_count} links completed               "
    end
  end
end
