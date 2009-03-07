class FixRevisedAtDates < ActiveRecord::Migration
  def self.up
    ThinkingSphinx.deltas_enabled=false
    Work.find(:all, :conditions => {:revised_at => nil}).each do |w|
      w.update_attribute(:revised_at, w.published_at)
    end
    ThinkingSphinx.deltas_enabled=true  
  end
  
  def self.down
  end
end
