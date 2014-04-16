class AddStatusToWorks < ActiveRecord::Migration
  def self.up
	change_table :works do |t|
		t.string :status
	end
	Work.reset_column_information
	Work.where(:complete => true).update_all(:status => 'complete')
	Work.where(:complete => [false, nil]).update_all(:status => 'wip')
  end

  def self.down
	remove_column :works, :status
  end
end