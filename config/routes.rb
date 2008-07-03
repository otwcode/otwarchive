ActionController::Routing::Routes.draw do |map|
  
  map.feedbacks '/feedback/fix', :controller => 'feedbacks', :action => 'create', :path_prefix => ':locale'
  map.new_abuse_report '/feedback/', :controller => 'feedbacks', :action => 'new', :path_prefix => ':locale'

  map.resources :tag_relationships, :path_prefix => ':locale'

  map.resources :tag_categories, :path_prefix => ':locale'

  map.resources :tags, :path_prefix => ':locale'

  map.root :controller => 'session', :action => 'new', :locale => 'en'      

  map.abuse_reports '/abuse/fix', :controller => 'abuse_reports', :action => 'create', :path_prefix => ':locale'
  map.new_abuse_report '/abuse/', :controller => 'abuse_reports', :action => 'new', :path_prefix => ':locale'
  
  map.resources :passwords, :path_prefix => ':locale'
  
  map.resources :admins, :path_prefix => ':locale'

  map.resources :users, :path_prefix => ':locale' do |user|
    user.resources :pseuds, :has_many => :works
    user.resource :profile, :controller => 'profile'
    user.resource :inbox, :controller => 'inbox'
    user.resources :bookmarks
    user.resources :works
    user.resources :readings
    user.resources :comments, :member => { :approve => :put, :reject => :put } 
  end
  
  map.resources :works, :member => { :preview => :get, :post => :post }, :path_prefix => ':locale' do |work|
    work.resources :chapters, :has_many => :comments, :collection => {:manage => :get, :update_positions => :post}, :member => { :preview => :get, :post => :post }
    work.resources :bookmarks
  end
  
  map.resources :chapters, :has_many => :comments, :member => { :preview => :get, :post => :post }, :path_prefix => ':locale'
  
  map.resources :comments, :has_many => :comments, :path_prefix => ':locale', :member => { :approve => :put, :reject => :put }

  map.resources :bookmarks, :path_prefix => ':locale'
  
  map.resources :external_works, :has_many => :bookmarks, :path_prefix => ':locale' 

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
