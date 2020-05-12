class KudosSweeper < ActionController::Caching::Sweeper
  observe Kudo

  def after_create(kudo)
    if kudo.commentable_type == "Work"
      # delete the cache entry for the total kudos count on the work
      Rails.cache.delete "works/#{kudo.commentable_id}/kudos_count-v2"
      # if guest kudo, delete the cache entry for guest_kudos_count to avoid guest kudos being stuck
      Rails.cache.delete "works/#{kudo.commentable_id}/guest_kudos_count-v2" if kudo.user_id.nil?
    end

    # expire the cache for the kudos section in the view
    # and for the full-page, expanded list
    ActionController::Base.new.expire_fragment("#{kudo.commentable.cache_key}/kudos-v2")
    ActionController::Base.new.expire_fragment("#{kudo.commentable.cache_key}/kudos/full-v2")
  end
end
