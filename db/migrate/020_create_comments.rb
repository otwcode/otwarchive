class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|    
      t.references  :pseud
      t.text        :content  
      t.integer     :depth, :threaded_left, :threaded_right
      t.boolean     :is_deleted
      t.string      :name, :email, :ip_address
      t.integer     :commentable_id
      t.string      :commentable_type
      t.timestamps   
    end      
  end

  def self.down     
    drop_table  :comments
  end
end