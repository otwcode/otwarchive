class AddVersionsToExisting < ActiveRecord::Migration
  def self.up
    Work.find(:all).each do |work|
      work.major_version = 1;
      work.minor_version = 0;
      work.save!
    end
  end

  def self.down
    # nothing
  end
end
