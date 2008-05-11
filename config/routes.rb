ActionController::Routing::Routes.draw do |map|         
  map.root :controller => 'session', :action => 'new', :locale => 'en'      

  map.abuse_reports '/abuse/fix', :controller => 'abuse_reports', :action => 'create', :path_prefix => ':locale'
  map.new_abuse_report '/abuse/', :controller => 'abuse_reports', :action => 'new', :path_prefix => ':locale'
  
  map.resources :passwords, :path_prefix => ':locale'
  
  map.resources :admins, :path_prefix => ':locale'

  map.resources :users, :has_many => :pseuds, :path_prefix => ':locale'
  
  map.resources :works, :has_many => :comments, :member => { :preview => :get, :post => :post }, :path_prefix => ':locale' do |work|
    work.resources :chapters, :has_many => :comments, :member => { :preview => :get, :post => :post }
  end
  
  map.resources :comments, :has_many => :comments, :path_prefix => ':locale'

  map.resources :bookmarks, :path_prefix => ':locale'

  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }, :path_prefix => ':locale'
  
  map.resource :session, :controller => 'session', :path_prefix => ':locale'
  map.login '/login', :controller => 'session', :action => 'new', :path_prefix => ':locale'
  map.logout '/logout', :controller => 'session', :action => 'destroy', :path_prefix => ':locale'
  
  map.resource :admin_session, :controller => 'admin_session', :path_prefix => ':locale'
  map.admin_login '/admin_login', :controller => 'admin_session', :action => 'new', :path_prefix => ':locale'
  map.admin_logout '/admin_logout', :controller => 'admin_session', :action => 'destroy', :path_prefix => ':locale'
  
  map.activate '/activate/:id', :controller => 'users', :action => 'activate'
  
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
  map.connect ':locale/:controller/:action/:id'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
