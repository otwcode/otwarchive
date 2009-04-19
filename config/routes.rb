ActionController::Routing::Routes.draw do |map|

  map.resources :invitations, :only => [:new, :create] 

  map.resources :media, :only => [:index, :show] 
  
  map.resources :people, :only => :index

  map.feedbacks '/feedback/', :controller => 'feedbacks', :action => 'create' , :conditions => { :method => :post }
  map.new_feedback_report '/feedback/', :controller => 'feedbacks', :action => 'new' 

  map.resources :tag_wranglings , :member => {:assign => :get}, :only => [:index, :create, :edit]

  map.resources :tags, :collection => {:show_hidden => :get} , :requirements => { :id => %r([^/;,?]+) } do |tag|
    tag.with_options :requirements => { :tag_id => %r([^/;,?]+) } do |tag_requirements|
        tag_requirements.resources :works
        tag_requirements.resources :bookmarks
    end
	end

  map.root :controller => 'home', :action => 'index'
  map.connect 'home/:action', :controller => "home" 
  map.tos '/tos', :controller => 'home', :action => 'tos' 
  map.tos_faq '/tos_faq', :controller => 'home', :action => 'tos_faq' 
  
  map.resources :abuse_reports, :except => [:edit, :update, :destroy] 

  map.resources :passwords, :only => [:new, :create] 

  map.resources :admins, :only => [:index, :show] 

  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new' 
  map.resources :users  do |user|
    user.resources :pseuds, :has_many => [:works, :series, :bookmarks]
    user.resources :preferences, :only => [:index, :update]
    user.resource :profile, :controller => 'profile', :only => :show
    user.resource :inbox, :controller => 'inbox', :collection => {:reply => :get, :cancel_reply => :get}, :only => [:show, :update]
    user.resources :bookmarks
    user.resources :works, :collection => {:drafts => :get}
    user.resources :series, :member => {:manage => :get}, :has_many => :serial_works
    user.resources :readings, :only => [:index, :destroy]
    user.resources :comments, :member => { :approve => :put, :reject => :put }
  end

  map.delete_confirmation '/delete_confirmation', :controller => 'users', :action => 'delete_confirmation'

  map.resources :works,
                :collection => {:upload_work => :post},
                :member => { :preview => :get, :post => :post } do |work|
      work.resources :chapters, :has_many => :comments,
                                :collection => {:manage => :get,
                                                :update_positions => :post},
                                :member => { :preview => :get, :post => :post }
      work.resources :comments, :member => { :approve => :put, :reject => :put }
      work.resources :bookmarks
  end

  map.resources :chapters, :has_many => :comments, :member => { :preview => :get, :post => :post } 

  map.resources :comments,
    :has_many => :comments,
    :member => { :approve => :put, :reject => :put },
    :collection => {:hide_comments => :get, :show_comments => :get,
                    :add_comment => :get, :cancel_comment => :get,
                    :add_comment_reply => :get, :cancel_comment_reply => :get,
                    :cancel_comment_edit => :get, :delete_comment => :get ,
                    :cancel_comment_delete => :get}

  map.resources :bookmarks 
  
  # should stay below the main works mapping
  map.resources :languages do |language|
    language.resources :works
  end
  
  map.resources :locales, :collection => {:set => :get} do |locale|
    locale.resources :translations, :collection => {:assign => :post}
    locale.resources :translators do |translator|
      translator.resources :translations
    end
    locale.resources :translation_notes
  end
  
  map.resources :translations, :collection => {:assign => :post}
  map.resources :translators, :has_many => :translations
  map.resources :translation_notes

  map.resources :orphans, :collection => {:about => :get}, :only => [:index, :new, :create] 

  map.resources :external_works, :has_many => :bookmarks, :only => :new 

  map.resources :communities 

  map.resources :related_works, :except => [:new, :edit, :create] 
  map.resources :serial_works, :only => :destroy 

  map.resources :series , :member => {:manage => :get, :update_positions => :post}

  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get } 

  map.resource :session, :controller => 'session' 
  map.login '/login', :controller => 'session', :action => 'new' 
  map.logout '/logout', :controller => 'session', :action => 'destroy' 

  map.admin_login '/admin/login', :controller => 'admin/admin_session', :action => 'new' 
  map.admin_logout '/admin/logout', :controller => 'admin/admin_session', :action => 'destroy' 

  map.namespace :admin, :path_prefix => 'admin' do |admin|
    admin.resources :user_creations, :only => :destroy, :member => { :hide => :get }
    admin.resources :users, :controller => 'admin_users', :collection => {:notify => :get, :send_notification => :post}, :except => [:new, :create]
    admin.resources :invitations, :controller => 'admin_invitations', :only => [:index, :new, :create]
    admin.resource :session, :controller => 'admin_session', :only => [:new, :create, :destroy]
  end

  map.activate '/activate/:id', :controller => 'users', :action => 'activate'
  
  # to preserve links with locales in the route
  map.with_locale '/en/works/:id', :controller => 'works', :action => 'show', :id => :id
  
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
