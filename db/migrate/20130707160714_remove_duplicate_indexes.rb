## Database Changes in reference to issue 3428
## Last Updated 10-29-2013 - Stephanie
class RemoveDuplicateIndexes < ActiveRecord::Migration
  def self.up
    remove_index(:challenge_claims , :name => 'index_challenge_claims_on_creation_id')
    remove_index(:creatorships, :name => 'index_creatorships_creation')
    remove_index(:kudos, :name => 'index_kudos_on_commentable_id_and_commentable_type')
    remove_index(:bookmarks, :name => 'index_bookmarkable')
  end

  def self.down
    add_index(:challenge_claims, [:creation_id], :name => 'index_challenge_claims_on_creation_id')
    add_index(:creatorships, [:creation_id,:creation_type], :name => 'index_creatorships_creation')
    add_index(:kudos, [:commentable_id,:commentable_type], :name => 'index_kudos_on_commentable_id_and_commentable_type')
    add_index(:bookmarks, [:bookmarkable_id,:bookmarkable_type], :name => 'index_bookmarkable')
  end
end

