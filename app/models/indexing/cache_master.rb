class CacheMaster

  ###################
  # CLASS METHODS
  ###################

  def self.expire_caches(work_ids)
    work_ids.each { |id| self.new(id).expire }
  end

  def self.record(work_id, owner_type, owner_id)
    self.new(work_id).record(owner_type, owner_id)
  end

  ###################
  # INSTANCE METHODS
  ###################

  attr_reader :work_id

  def initialize(work_id)
    @work_id = work_id
  end

  def key
    "works:#{work_id}:assocs"
  end

  def get_hash
    REDIS_GENERAL.hgetall(key)
  end

  def get_value(owner_type)
    REDIS_GENERAL.hget(key, owner_type)
  end

  def set_value(owner_type, value)
    REDIS_GENERAL.hset(key, owner_type, value)
  end

  def reset!
    REDIS_GENERAL.del(key)
  end

  def record(owner_type, owner_id)
    owner_type = owner_type.to_s
    data = get_value(owner_type)
    value = data.nil? ? owner_id.to_s : "#{data},#{owner_id}"
    set_value(owner_type, value)
  end

  def expire
    get_hash.each_pair do |key, id_string|
      klass = key.classify.constantize
      klass.expire_ids(id_string.split(','))
    end
    reset!
  end

end