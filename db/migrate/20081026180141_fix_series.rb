class FixSeries < ActiveRecord::Migration
  def self.up
    Series.all.each do |s|
      if s.works.empty? && s.pseuds.empty?
        s.destroy 
      else
        s.works.map(&:pseuds).flatten.each do |p|
          s.pseuds << p unless s.pseuds.include? p
        end
      end
    end
  end

  def self.down
  end
end
