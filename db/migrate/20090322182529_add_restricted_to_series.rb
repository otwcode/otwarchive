class AddRestrictedToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :restricted, :boolean, :default => false, :null => false
    Series.reset_column_information
    Series.all.each do |series|
      restr = true
      series.works.each do |w|
        restr = restr && w.restricted
      end
      series.update_attribute(:restricted, restr)
    end
  end

  def self.down
    remove_column :series, :restricted
  end
end
