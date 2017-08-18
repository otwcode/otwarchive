# encoding=utf-8

require 'nokogiri'

class WordCounter

  attr_accessor :text

  def initialize(text)
    @text = text
  end

  # only count actual text
  # scan by word boundaries after stripping hyphens and apostrophes
  # so one-word and one's will be counted as one word, not two.
  # -- is replaced by — (emdash) before strip so one--two will count as 2
  def count
    count = 0
    body = Nokogiri::HTML(@text).xpath('//body').first
    body.traverse do |node|
      if node.is_a? Nokogiri::XML::Text
        count += node.inner_text.gsub(/--/, "—").gsub(/['’‘-]/, "").scan(/[[:word:]]+/).size
      end
    end
    count
  end

end
