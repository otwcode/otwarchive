class CreateExternalAuthorsAndCreatorships < ActiveRecord::Migration
  def self.up
    
    # start with the external authors table
    create_table :external_authors do |t|
      t.string :email
      t.boolean :is_claimed, :default => false, :null => false
      t.references :user
      t.boolean :do_not_email, :default => false, :null => false
      t.boolean :do_not_import, :default => false, :null => false

      t.timestamps
    end

    # create author names table
    create_table :external_author_names do |t|
      t.references :external_author, :null => false 
      t.string :name

      t.timestamps
    end

    # create the polymorphic table to hold creatorships by external authors
    create_table :external_creatorships do |t|
      t.references :creation, :polymorphic => true
      t.references :external_author

      t.timestamps
    end

  end

  def self.down
    drop_table :external_creatorships
    drop_table :external_author_names
    drop_table :external_authors
  end
end
