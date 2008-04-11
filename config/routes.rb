ActionController::Routing::Routes.draw do |map|
  map.resources :pseuds
                          
  map.activate '/activate/:id', :controller => 'users', :action => 'activate'    
  
  map.root :controller => 'session', :action => 'new'      
  
  map.resources :passwords
  
  map.resources :admins

  map.resources :users

  map.resources :works, :has_many => :chapters

  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }
  
  map.resource :session, :controller => 'session'
  map.login '/login', :controller => 'session', :action => 'new'
  map.logout '/logout', :controller => 'session', :action => 'destroy'
  
  map.resource :admin_session, :controller => 'admin_session'
  map.admin_login '/admin_login', :controller => 'admin_session', :action => 'new'
  map.admin_logout '/admin_logout', :controller => 'admin_session', :action => 'destroy'
  


  # BERO delete
  # map.resources :chapters
  #map.resources :works

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => :works

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
