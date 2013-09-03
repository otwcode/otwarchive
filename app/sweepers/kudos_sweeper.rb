class KudosSweeper < ActionController::Caching::Sweeper
  observe Kudo
  
  def after_create(kudo)
    expire_fragment "#{kudo.commentable.cache_key}/kudos"
  end
  
end
