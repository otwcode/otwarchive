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
  #
  # Scripts such as Chinese and Japanese that do not have space between words
  # are counted based on the number of characters. If a text include mixed
  # languages, only characters in these languages would be counted as words,
  # words in other languages are counted normally
  def count
    count = 0
    # avoid blank? so we don't need to load Rails for tests
    return count if @text.nil? || @text.empty?
    body = Nokogiri::HTML(@text).xpath('//body').first
    body.traverse do |node|
      if node.is_a? Nokogiri::XML::Text
        # includes Chinese, Japanese and Thai
        languages_without_spaces = "\\p{Han}|\\p{Katakana}|\\p{Hiragana}|\\p{Thai}"
        count += node.inner_text.gsub(/--/, "—").gsub(/['’‘-]/, "")
                .scan(/[#{languages_without_spaces}]|((?!#{languages_without_spaces})[[:word:]])+/).size
      end
    end
    count
  end

end
