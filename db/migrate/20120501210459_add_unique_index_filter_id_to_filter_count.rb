class AddUniqueIndexFilterIdToFilterCount < ActiveRecord::Migration
  def self.up
    # first get rid of duplicates!
    invalid_filter_counts = FilterCount.group(:filter_id).having("COUNT(filter_id) > 1")
    invalid_filter_counts.each do |ifc|
      # identify duplicates
      filter_counts_to_remove = FilterCount.where(:filter_id => ifc.filter_id)
      # preserve one of them
      filter_counts_to_remove.shift
      # delete the others
      filter_counts_to_remove.each {|fc| fc.destroy }

      # refresh the affected filter tags to be up to date
      Tag.where(:id => ifc.filter_id).each do |filter_tag|
        begin
          filter_tag.reset_filter_count
        rescue
          puts "Problem resetting #{filter_tag.name}"
        end
      end
    end

    # replace the index with a unique index, which will not allow duplicates in the future
    remove_index :filter_counts, :filter_id
    add_index :filter_counts, :filter_id, :unique => true
  end

  def self.down
    remove_index :filter_counts, :filter_id
    add_index :filter_counts, :filter_id, :unique => false
  end
end
