Otwarchive::Application.routes.draw do

  #### DOWNLOADS ####

  match 'downloads/:download_authors/:id/:download_title.:format' => 'works#download', :as => 'download'


  #### INVITATIONS ####

  resources :invitations  
  resources :user_invite_requests
  resources :invite_requests do
    collection do
      get :manage
      post :reorder
    end
  end
  
  match 'signup/:invitation_token' => 'users#new', :as => 'signup'
  match 'claim/:invitation_token' => 'external_authors#claim', :as => 'claim'
  match 'complete_claim/:invitation_token' => 'external_authors#complete_claim', :as => 'complete_claim'
    
  #### TAGS ####
  
  resources :media do
    resources :fandoms
  end
  resources :fandoms do
    collection do
      get :unassigned
    end
  end
  resources :tag_wranglings do
    member do
      post :wrangle
    end
    collection do
      get :discuss
    end
  end
  resources :tag_wranglers
  resources :tags do
    member do
      # anything you add here will need a match under globbing at the top
      get :wrangle
      post :mass_update
      get :remove_association
    end
    collection do
      get :show_hidden
      get :search
    end
    resources :works
    resources :bookmarks
    resources :comments
	end
    
  
  #### ADMIN ####
  resources :admins
  resources :admin_posts do
    resources :comments
  end
  
  resources :admin_sessions

  match '/admin/login' => 'admin_sessions#new' 
  match '/admin/logout' => 'admin_sessions#destroy'

  namespace :admin do
    resources :settings
    resources :approve_skins
    resources :skins do
      collection do
        get :index_rejected
        get :index_approved
      end
    end
    resources :user_creations do
      member do
        get :hide
      end
    end
    resources :users, :controller => 'admin_users' do
      collection do
        get :notify
        post :send_notification
        post :update_user
      end
    end
    resources :invitations, :controller => 'admin_invitations' do
      collection do
        post :invite_from_queue
        post :grant_invites_to_users
        get :find
      end
    end
  end
  
  
  #### USERS ####
  
  resources :people do
    collection do
      get :search
    end
  end
  
  resources :passwords
  
  # When adding new nested resources, please keep them in alphabetical order
  resources :users do
    member do
      get :change_openid
      post :change_openid
      get :change_password
      post :change_password
      get :change_username
      post :change_username
      post :end_first_login
    end
    resources :assignments, :controller => "challenge_assignments" do
      member do
        get :default
      end
    end    
    resources :bookmarks
    resources :collection_items, :only => [:index, :update, :destroy]
    resources :collections, :only => [:index]
    resources :comments do
      member do
        put :approve
        put :reject
      end
    end
    resources :external_authors do
      resources :external_author_names
    end
    resources :gifts, :only => [:index]
    resource :inbox, :controller => "inbox" do
      member do
        get :reply
        get :cancel_reply
      end
    end 
    resources :invitations do
      member do 
        post :invite_friend
      end
      collection do
        get :manage
      end
    end
    resources :preferences, :only => [:index, :update]
    resource :profile, :only => [:show], :controller => "profile"
    resources :pseuds do
      resources :works
      resources :series
      resources :bookmarks
    end
    resources :readings do
      member do
        get :marktoread
      end
      collection do
        post :clear
      end
    end
    resources :related_works
    resources :series do
      member do
        get :manage
      end
      resources :serial_works
    end
    resources :signups, :controller => "challenge_signups", :only => [:index]
    resources :skins, :only => [:index]
    resources :works do
      collection do
        get :drafts
        get :show_multiple
        post :edit_multiple
        put :update_multiple
      end
    end
  end 
  
  
  #### WORKS ####
  
  resources :works do
    collection do
      post :import
      get :search
    end
    member do
      get :preview
      post :post
      put :post_draft
      get :navigate
      get :edit_tags
      get :preview_tags
      put :update_tags
      get :marktoread
    end
    resources :bookmarks
    resources :chapters do
      collection do
        get :manage
        post :update_positions
      end
      member do
        get :preview
        post :post
      end
      resources :comments
    end
    resources :collections
    resources :collection_items
    resources :comments do
      member do
        put :approve
        put :reject
      end
    end
  end
  
  resources :chapters do
    member do
      get :preview
      post :post
    end
    resources :comments
  end  

  resources :external_works do
    collection do
      get :compare
      post :merge
    end
    resources :bookmarks
    resources :related_works
  end
  resources :related_works 
  resources :serial_works 
  resources :series do
    member do
      get :manage
      post :update_positions
    end
    resources :bookmarks
  end
  
  #### COLLECTIONS ####
  
  resources :gifts
  resources :prompt_restrictions
  resources :prompts
  resources :collections do
    resource  :profile, :controller => "collection_profile"
    resources :collections
    resources :works
    resources :gifts
    resources :bookmarks
    resources :media
    resources :fandoms
    resources :people
    resources :tags do
      resources :works
    end
    resources :participants, :controller => "collection_participants" do
      collection do
        get :add
        get :join
      end
    end
    resources :items, :controller => "collection_items"
    resources :signups, :controller => "challenge_signups" do
      collection do
        get :summary
      end
    end
    resources :assignments, :controller => "challenge_assignments" do
      collection do
        get :generate
        put :set
        get :purge
        get :send_out
        put :default_multiple
        get :default_all
      end
      member do
        get :undefault
        get :cover_default
        get :uncover_default
      end 
    end
    resources :potential_matches do
      collection do
        get :generate
        get :cancel_generate
      end
    end
    # challenge types
    resource :gift_exchange, :controller => 'challenge/gift_exchange'
  end 
  
  #### I18N ####
  
  # should stay below the main works mapping
  resources :languages do
    resources :works
  end 
  resources :locales do
    collection do
      get :set
    end
    resources :translations do
      collection do
        post :assign
      end
    end
    resources :translators do
      resources :translations
    end
    resources :translation_notes
  end
  
  resources :translations do
    collection do
      post :assign
    end
  end
  resources :translators do
    resources :translations
  end
  resources :translation_notes
  
  #### SESSIONS ####
  
  resources :user_sessions
  match 'login' => 'user_sessions#new'
  match 'logout' => 'user_sessions#destroy' 
    
  #### MISC ####
  
  resources :comments do
    member do
      put :approve
      put :reject
    end
    collection do
      get :hide_comments
      get :show_comments
      get :add_comment
      get :cancel_comment
      get :add_comment_reply
      get :cancel_comment_reply
      get :cancel_comment_edit
      get :delete_comment
      get :cancel_comment_delete
    end
    resources :comments
  end
  resources :bookmarks do
    collection do
      get :search
    end
  end
  
  resources :skins
  resources :known_issues
  resources :archive_faqs do
    collection do
      get :manage
      post :reorder
    end
  end
  
  resources :redirects  
  resources :abuse_reports 
  resources :external_authors do
    resources :external_author_names
  end
  resources :orphans do
    collection do
      get :about
    end
  end
  resources :search, :only => :index
  
  match 'search' => 'search#index'
  match 'support' => 'feedbacks#create', :as => 'feedbacks', :via => [:post]
  match 'support' => 'feedbacks#new', :as => 'new_feedback_report', :via => [:get]
  match 'tos' => 'home#tos'
  match 'tos_faq' => 'home#tos_faq'
  match 'site_map' => 'home#site_map'
  match 'first_login_help' => 'home#first_login_help'
  match 'delete_confirmation' => 'users#delete_confirmation'
  match 'activate/:id' => 'users#activate', :as => 'activate'
  match 'devmode' => 'devmode#index'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
