class KudosSweeper < ActionController::Caching::Sweeper
  observe Kudo

  def after_create(kudo)
    # invalidates the cache for the kudos section in the view
    expire_fragment "#{kudo.commentable.cache_key}/kudos"

    if kudo.commentable_type == "Work"
      # expire the total kudos count on the work
      expire_fragment "works/#{kudo.commentable_id}/kudos_count"
      # if this is a guest kudo, expire the guest_kudos_count to avoid guest kudos being stuck
      expire_fragment "works/#{kudo.commentable_id}/guest_kudos_count" if kudo.pseud_id.nil?
    end
  end

  def after_update(kudo)
    return unless kudo.pseud_id_changed?

    expire_fragment "#{kudo.commentable.cache_key}/kudos"

    if kudo.commentable_type == "Work"
      # if someone has deleted their account: expire guest kudos count
      expire_fragment "works/#{kudo.commentable_id}/guest_kudos_count" if kudo.pseud_id.nil?
    end
  end
end
