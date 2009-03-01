ActionController::Routing::Routes.draw do |map|
  map.resources :invitations, :path_prefix => ':locale'

  map.resources :media, :path_prefix => ':locale'

  map.feedbacks '/feedback/', :controller => 'feedbacks', :action => 'create', :path_prefix => ':locale', :conditions => { :method => :post }
  map.new_feedback_report '/feedback/', :controller => 'feedbacks', :action => 'new', :path_prefix => ':locale'

  map.resources :tag_wranglings, :path_prefix => ':locale', :member => {:assign => :get}

  map.resources :tags, :collection => {:show_hidden => :get}, :path_prefix => ':locale', :requirements => { :id => %r([^/;,?]+) } do |tag|
    tag.with_options :requirements => { :tag_id => %r([^/;,?]+) } do |tag_requirements|
        tag_requirements.resources :works
        tag_requirements.resources :bookmarks
    end
	end

  map.root :controller => 'home', :action => 'index', :locale => 'en'
  map.connect 'home/:action', :controller => "home", :path_prefix => ':locale'
  map.tos '/tos', :controller => 'home', :action => 'tos', :path_prefix => ':locale'
  map.tos_faq '/tos_faq', :controller => 'home', :action => 'tos_faq', :path_prefix => ':locale'

  map.translate '/translate/:controller_to_translate/:action_to_translate', :controller => 'translation', :action => 'translate', :path_prefix => ':locale'

  map.resources :abuse_reports, :path_prefix => ':locale'

  map.resources :passwords, :path_prefix => ':locale'

  map.resources :admins, :path_prefix => ':locale'

  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new', :path_prefix => ':locale'
  map.resources :users, :path_prefix => ':locale' do |user|
    user.resources :pseuds, :has_many => :works
    user.resources :preferences
    user.resource :profile, :controller => 'profile'
    user.resource :inbox, :controller => 'inbox', :collection => {:reply => :get, :cancel_reply => :get}
    user.resources :bookmarks
    user.resources :works, :collection => {:drafts => :get}
    user.resources :series, :member => {:manage => :get}, :has_many => :serial_works
    user.resources :readings
    user.resources :comments, :member => { :approve => :put, :reject => :put }
  end

  map.delete_confirmation '/delete_confirmation', :controller => 'users', :action => 'delete_confirmation',
                :path_prefix => ':locale'

  map.resources :works,
                :collection => {:upload_work => :post},
                :member => { :preview => :get, :post => :post },
                :path_prefix => ':locale' do |work|
      work.resources :chapters, :has_many => :comments,
                                :collection => {:manage => :get,
                                                :update_positions => :post},
                                :member => { :preview => :get, :post => :post }
      work.resources :comments, :member => { :approve => :put, :reject => :put }
      work.resources :bookmarks
  end

  map.resources :chapters, :has_many => :comments, :member => { :preview => :get, :post => :post }, :path_prefix => ':locale'

  map.resources :comments,
    :has_many => :comments,
    :path_prefix => ':locale',
    :member => { :approve => :put, :reject => :put },
    :collection => {:hide_comments => :get, :show_comments => :get,
                    :add_comment => :get, :cancel_comment => :get,
                    :add_comment_reply => :get, :cancel_comment_reply => :get,
                    :cancel_comment_edit => :get, :delete_comment => :get ,
                    :cancel_comment_delete => :get}

  map.resources :bookmarks, :path_prefix => ':locale'

  map.resources :orphans, :collection => {:about => :get}, :path_prefix => ':locale'

  map.resources :external_works, :has_many => :bookmarks, :path_prefix => ':locale'

  map.resources :communities, :path_prefix => ':locale'

  map.resources :related_works, :path_prefix => ':locale'
  map.resources :serial_works, :path_prefix => ':locale'

  map.resources :series, :path_prefix => ':locale', :member => {:manage => :get, :update_positions => :post}, :has_many => :serial_works

  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }, :path_prefix => ':locale'

  map.resource :session, :controller => 'session', :path_prefix => ':locale'
  map.login '/login', :controller => 'session', :action => 'new', :path_prefix => ':locale'
  map.logout '/logout', :controller => 'session', :action => 'destroy', :path_prefix => ':locale'

  map.admin_login '/admin/login', :controller => 'admin/admin_session', :action => 'new', :path_prefix => ':locale'
  map.admin_logout '/admin/logout', :controller => 'admin/admin_session', :action => 'destroy', :path_prefix => ':locale'


  map.namespace :admin, :path_prefix => ':locale/admin' do |admin|
    admin.resources :user_creations, :member => { :hide => :get }
    admin.resources :users, :controller => 'admin_users', :collection => {:notify => :get, :send_notification => :post}
    admin.resources :invitations, :controller => 'admin_invitations'
    admin.resource :session, :controller => 'admin_session'
  end

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
