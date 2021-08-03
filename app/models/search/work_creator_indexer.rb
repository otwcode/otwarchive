# A class for reindexing private work creator info (info that should not be
# available during normal searches).
class WorkCreatorIndexer < Indexer
  def self.klass
    "Work"
  end

  def self.mapping
    WorkIndexer.mapping
  end

  def routing_info(id)
    {
      "_index" => index_name,
      "_type" => document_type,
      "_id" => document_id(id),
      "routing" => parent_id(id, nil)
    }
  end

  def document_id(id)
    "#{id}-creator"
  end

  def parent_id(id, _object)
    id
  end

  def document(object)
    {
      private_user_ids: object.user_ids,
      private_pseud_ids: object.pseud_ids,
      creator_join: {
        name: :creator,
        parent: object.id
      }
    }
  end
end
