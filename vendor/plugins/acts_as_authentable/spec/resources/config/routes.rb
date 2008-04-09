ActionController::Routing::Routes.draw do |map|
    map.resources :users

    # Singleton resource. A user can only have one session.
    map.resource :session
end
