class CreateCollectionParticipants < ActiveRecord::Migration
  def self.up
    create_table :collection_participants do |t|
      t.references :collection
      t.references :pseud
      t.string :participant_role, :null => false, :default => CollectionParticipant::NONE
      t.timestamps
    end
  end

  def self.down
    drop_table :collection_participants
  end
end
