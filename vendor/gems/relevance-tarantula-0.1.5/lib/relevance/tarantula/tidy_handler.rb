require 'rubygems'
begin
  gem 'tidy'
  require 'tidy'
rescue Gem::LoadError
  # tidy not available
end

if defined? Tidy
  Tidy.path = ENV['TIDY_PATH'] if ENV['TIDY_PATH']

  class Relevance::Tarantula::TidyHandler 
    include Relevance::Tarantula
    def initialize(options = {})
      @options = {:show_warnings=>true}.merge(options)
    end
    def handle(result)
      response = result.response
      return unless response.html?
      tidy = Tidy.open(@options) do |tidy|
        xml = tidy.clean(response.body)
        tidy
      end
      unless tidy.errors.blank?
        error_result = result.dup
        error_result.description = "Bad HTML (Tidy)"
        error_result.data = tidy.errors.inspect
        error_result
      end
    end
  end
end
