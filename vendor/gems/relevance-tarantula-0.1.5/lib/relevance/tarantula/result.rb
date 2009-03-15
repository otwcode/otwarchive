class Relevance::Tarantula::Result
  HASHABLE_ATTRS = [:success, :method, :url, :response, :referrer, :data, :description, :log, :test_name]
  DEFAULT_LOCALHOST = "http://localhost:3000"
  attr_accessor *HASHABLE_ATTRS
  include Relevance::Tarantula
  include Relevance::Tarantula::HtmlReportHelper

  def initialize(hash)
    hash.each do |k,v|
      raise ArgumentError, k unless HASHABLE_ATTRS.member?(k)
      self.instance_variable_set("@#{k}", v)
    end
  end
  def short_description
    [method,url].join(" ")
  end
  def sequence_number
    @sequence_number ||= (self.class.next_number += 1)
  end
  def file_name
    "#{sequence_number}.html"
  end
  def code
    response && response.code
  end
  def body
    response && response.body
  end
  def full_url
    "#{DEFAULT_LOCALHOST}#{url}"
  end
  ALLOW_NNN_FOR = /^allow_(\d\d\d)_for$/
  class << self
    attr_accessor :next_number
    def handle(result)
      retval = result.dup
      retval.success = successful?(result.response) || can_skip_error?(result)
      retval.description = "Bad HTTP Response" unless retval.success
      retval
    end
    def success_codes 
      %w{200 201 302 401}
    end
    
    # allow_errors_for is a hash 
    #  k=error code,
    #  v=array of matchers for urls that can skip said error
    attr_accessor :allow_errors_for
    def can_skip_error?(result)
      coll = allow_errors_for[result.code]
      return false unless coll
      coll.any? {|item| item === result.url}
    end
    def successful?(response)
      success_codes.member?(response.code)
    end
    def method_missing(meth, *args)  
      super unless ALLOW_NNN_FOR =~ meth.to_s
      (allow_errors_for[$1] ||= []).push(*args)
    end
  end
  self.allow_errors_for = {}
  self.next_number = 0
  
  
end