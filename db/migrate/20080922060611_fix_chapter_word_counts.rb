class FixChapterWordCounts < ActiveRecord::Migration
  def self.up
    full_sanitizer = HTML::FullSanitizer.new
    Chapter.all.each {|c| c.update_attribute(:word_count, full_sanitizer.sanitize(c.content).split.length)}
    Work.all.each {|w| w.update_attribute(:word_count, w.chapters.collect(&:word_count).compact.sum)}
  end

  def self.down
  end
end
