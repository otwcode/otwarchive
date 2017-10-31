# ES UPGRADE TRANSITION #
# Change all instances of $new_elasticsearch to $elasticsearch
class Indexer

  BATCH_SIZE = 1000

  ##################
  # CLASS METHODS
  ##################

  def self.klass
    raise "Must be defined in subclass"
  end

  def self.delete_index
    if $new_elasticsearch.indices.exists(index: index_name)
      $new_elasticsearch.indices.delete(index: index_name)
    end
  end

  def self.create_index
    $new_elasticsearch.indices.create(
      index: index_name,
      body: {
        settings: {
          index: {
            number_of_shards: 5,
            # In preparation for ES 6.x, only a single document type is allowed
            # per index
            mapping: { single_type: true }
          }
        },
        mappings: mapping,
      }
    )
  end

  # Note that the index must exist before you can set the mapping
  def self.create_mapping
    $new_elasticsearch.indices.put_mapping(
      index: index_name,
      type: document_type,
      body: mapping
    )
  end

  def self.mapping
    {
      document_type => {
        properties: {
          #add properties in subclasses
        }
      }
    }
  end

  def self.index_all(options={})
    unless options[:skip_delete]
      delete_index
      create_index
    end
    index_from_db
  end

  def self.index_from_db
    total = (indexables.count / BATCH_SIZE) + 1
    i = 1
    indexables.find_in_batches(batch_size: BATCH_SIZE) do |group|
      puts "Queueing #{klass} batch #{i} of #{total}"
      AsyncIndexer.new(self, :world).enqueue_ids(group.map(&:id))
      i += 1
    end
  end

  # Add conditions here
  def self.indexables
    Rails.logger.info "Blueshirt: Logging use of constantize class self.indexables #{klass}"
    klass.constantize
  end

  def self.index_name
    "ao3_#{Rails.env}_#{klass.underscore.pluralize}"
  end

  def self.document_type
    klass.underscore
  end

  ####################
  # INSTANCE METHODS
  ####################

  attr_reader :ids

  def initialize(ids)
    @ids = ids
  end

  def klass
    self.class.klass
  end

  def index_name
    self.class.index_name
  end

  def document_type
    self.class.document_type
  end

  def objects
    Rails.logger.info "Blueshirt: Logging use of constantize class objects #{klass}"
    @objects ||= klass.constantize.where(id: ids).inject({}) do |h, obj|
      h.merge(obj.id => obj)
    end
  end

  def batch
    @batch = []
    ids.each do |id|
      object = objects[id.to_i]
      if object.present?
        @batch << { index: routing_info(id) }
        @batch << document(object)
      else
        @batch << { delete: routing_info(id) }
      end
    end
    @batch
  end

  def index_documents
    $new_elasticsearch.bulk(body: batch)
  end

  def routing_info(id)
    {
      '_index' => index_name,
      '_type' => document_type,
      '_id' => id
    }
  end

  def document(object)
    object.as_json(root: false)
  end

end
