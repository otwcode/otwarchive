class Akismetor
  attr_accessor :attributes
  
  # Does a comment-check on Akismet with the submitted hash.
  # Returns true or false depending on response.
  def self.spam?(attributes)
    self.new(attributes).execute('comment-check') != "false"
  end
  
  # Does a submit-spam on Akismet with the submitted hash.
  # Use this when Akismet incorrectly approves a spam comment.
  def self.submit_spam(attributes)
    self.new(attributes).execute('submit-spam')
  end
  
  # Does a submit-ham on Akismet with the submitted hash.
  # Use this for a false positive, when Akismet incorrectly rejects a normal comment
  def self.submit_ham(attributes)
    self.new(attributes).execute('submit-ham')
  end
  
  
  def initialize(attributes)
    @attributes = attributes
  end
  
  def execute(command)
    http = Net::HTTP.new("#{attributes[:key]}.rest.akismet.com", 80)
    response, content = http.post("/1.1/#{command}", attributes_for_post, http_headers)
    content
  end
  
private
  
  def http_headers
    {
      'User-Agent' => 'Akismetor Rails Plugin/1.0',
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end
  
  def attributes_for_post
    result = attributes.map { |k, v| "#{k}=#{v}" }.join('&')
    URI.escape(result)
  end
end
