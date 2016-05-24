class KudosSweeper < ActionController::Caching::Sweeper
  observe Kudo

  def after_create(kudo)
    if kudo.commentable_type == "Work"
      # delete the cache entry for the total kudos count on the work
      Rails.cache.delete "works/#{kudo.commentable_id}/kudos_count"
      # if guest kudo, delete the cache entry for guest_kudos_count to avoid guest kudos being stuck
      Rails.cache.delete "works/#{kudo.commentable_id}/guest_kudos_count" if kudo.pseud_id.nil?
    end

    # expire the cache for the kudos section in the view
    # and for the full-page, expanded list
    expire_fragment "#{kudo.commentable.cache_key}/kudos-v1"
    expire_fragment "#{kudo.commentable.cache_key}/kudos/full"
  end
end
