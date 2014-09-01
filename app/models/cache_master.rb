class CacheMaster

  def self.work_deletion_key(work_id)
    "works:#{work_id}:deleted_assocs"
  end

  def self.register_deletion(work_id, owner_type, owner_id)
    key = work_deletion_key(work_id)
    owner_type = owner_type.to_s
    data = REDIS_GENERAL.hget(key, owner_type)
    if data.nil?
      REDIS_GENERAL.hset(key, owner_type, owner_id)
    else
      new_data = "#{data},#{owner_id}"
      REDIS_GENERAL.hset(key, owner_type, new_data)
    end
  end

  def self.expire_caches(work_ids)
    work_ids.each do |id|
      REDIS_GENERAL.hgetall(work_deletion_key(id)).each_pair do |key, id_string|
        klass = key.classify.constantize
        klass.expire_caches(id_string.split(','))
      end
    end
  end

end