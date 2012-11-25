class WorkSweeper < ActionController::Caching::Sweeper
  observe Work, Chapter
  
  def after_save(record)
    changelist = record.changed.empty? ? [] : record.changed - %w(updated_at delta)
    expire_work_cache_for(record) unless changelist.empty?
  end

  def after_destroy(record)
    expire_work_cache_for(record)
  end
  
  private


  def expire_work_cache_for(record)
    # in case this is a chapter of the work
    work = record
    work = record.work if record.is_a?(Chapter)
    return unless work.present?

    # collect up everything we need to expire: pseuds, collections, tags
    to_expire = []

    work.pseuds.each do |pseud|
      to_expire << "pseud/#{pseud.id}"
      to_expire << "user/#{pseud.user_id}"
    end
    
    all_collections = work.all_collections.value_of(:id)
    all_collections.each do |collection_id|
      to_expire << "collection/#{collection_id}"
    end
    
    # all the tags and collections with those tags
    (work.taggings.value_of(:tag_id) | work.filter_taggings.value_of(:filter_id)).each do |tag_id|
      to_expire << "tag/#{tag_id}"
      all_collections.each do |collection_id|
        to_expire <<  "collection/#{collection_id}/tag/#{tag_id}"
      end
    end
    
    # Expire all the relevant index page keys
    # expire the first n cached pages for the tags on the work and the corresponding filter tags
    to_expire.uniq.each do |exp|
      5.times do |n|
        Rails.cache.delete("views/works/v2/#{exp}/u/p/#{n+1}")
        Rails.cache.delete("views/works/v2/#{exp}/v/p/#{n+1}")
      end
    end
  end
  
  

end
