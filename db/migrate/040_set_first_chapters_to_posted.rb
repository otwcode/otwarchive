class SetFirstChaptersToPosted < ActiveRecord::Migration
  def self.up
    # If work is posted, the first chapter should also be posted
    Work.find(:all, :conditions => 'posted = true').each do |work|
      work.chapters.first.posted = true
      work.chapters.first.save
    end
  end

  def self.down
  end
end
