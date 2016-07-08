Otwarchive::Application.routes.draw do
  devise_scope :user do
    get '/login'  => 'user/sessions#new'
    get '/logout' => 'user/session#destroy'
  end

  devise_for :user,
             controllers: { sessions: 'user/sessions' }

  devise_for :admin,
             controllers: { sessions: 'admin/sessions' },
             path_names: {
               sign_in: 'login',
               sign_out: 'logout'
             }

  # PATHS TO CHECK

  resources :passwords, only: [:new, :create]

  #### ERRORS ####

  match '/403', to: 'errors#403'
  match '/404', to: 'errors#404'
  match '/422', to: 'errors#422'
  match '/500', to: 'errors#500'

  #### DOWNLOADS ####

  match 'downloads/:download_prefix/:download_authors/:id/:download_title.:format' => 'downloads#show', as: 'download'

  #### OPEN DOORS ####
  namespace :opendoors do
    resources :tools, only: [:index] do
      collection do
        post :url_update
      end
    end
    resources :external_authors do
      member do
        post :forward
      end
    end
  end

  #### INVITATIONS ####

  resources :invitations
  resources :user_invite_requests
  resources :invite_requests do
    collection do
      get :manage
      post :reorder
    end
  end

  match 'signup/:invitation_token' => 'users#new', as: 'signup'
  match 'claim/:invitation_token' => 'external_authors#claim', as: 'claim'
  match 'complete_claim/:invitation_token' => 'external_authors#complete_claim', as: 'complete_claim'

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
  resources :unsorted_tags do
    collection do
      post :mass_update
    end
  end
  resources :tags do
    member do
      get :feed
      post :mass_update
      get :remove_association
      get :wrangle
    end
    collection do
      get :show_hidden
      get :search
    end
    resources :works
    resources :bookmarks
    resources :comments
  end

  resources :tag_sets, controller: 'owned_tag_sets' do
    resources :nominations, controller: 'tag_set_nominations' do
      collection do
        put  :update_multiple
        delete :destroy_multiple
        get  :confirm_destroy_multiple
      end
      member do
        get :confirm_delete
      end
    end
    resources :associations, controller: 'tag_set_associations', only: [:index] do
      collection do
        put :update_multiple
      end
    end
    member do
      get :batch_load
      put :do_batch_load
      get :confirm_delete
    end
    collection do
      get :show_options
    end
  end
  resources :tag_nominations, only: [:update]

  resources :tag_wrangling_requests, only: [:index] do
    collection do
      put :update_multiple
    end
  end

  #### ADMIN ####
  resources :admins
  resources :admin_posts do
    resources :comments
  end

  namespace :admin do
    resources :activities, only: [:index, :show]
    resources :banners do
      member do
        get :confirm_delete
      end
    end
    resources :blacklisted_emails, only: [:index, :new, :create, :destroy]
    resources :settings
    resources :skins do
      collection do
        get :index_rejected
        get :index_approved
      end
    end
    resources :user_creations, only: [:destroy] do
      member do
        get :hide
      end
    end
    resources :users, controller: 'admin_users' do
      member do
        get :confirm_delete_user_creations
        post :destroy_user_creations
      end
      collection do
        get :notify
        post :send_notification
        post :update_user
      end
    end
    resources :invitations, controller: 'admin_invitations' do
      collection do
        post :invite_from_queue
        post :grant_invites_to_users
        get :find
      end
    end
    resources :api
  end

  match '/admin/api/new', to: 'admin/api#create', via: :post

  #### USERS ####

  resources :people, only: [:index] do
    collection do
      get :search
    end
  end

  # When adding new nested resources, please keep them in alphabetical order
  resources :users do
    member do
      get :browse

      # CHECK BEFORE DEPLOYING DEVISE
      get :change_email
      post :changed_email
      get :change_password
      post :changed_password
      get :change_username
      post :changed_username
      post :end_first_login
      post :end_banner
    end
    resources :assignments, controller: "challenge_assignments", only: [:index] do
      collection do
        put :update_multiple
      end
      member do
        get :default
      end
    end
    resources :claims, controller: "challenge_claims", only: [:index]
    resources :bookmarks
    resources :collection_items, only: [:index, :update, :destroy] do
      collection do
        put :update_multiple
      end
    end
    resources :collections, only: [:index]
    resources :comments do
      member do
        put :approve
        put :reject
      end
    end
    resources :external_authors do
      resources :external_author_names
    end
    resources :favorite_tags, only: [:create, :destroy]
    resources :gifts, only: [:index]
    resource :inbox, controller: "inbox" do
      member do
        get :reply
        get :cancel_reply
        post :delete
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
    resources :nominations, controller: "tag_set_nominations", only: [:index]
    resources :preferences, only: [:index, :update]
    resource :profile, only: [:show], controller: "profile"
    resources :pseuds do
      resources :works
      resources :series
      resources :bookmarks
    end
    resources :readings do
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

    # CHECK BEFORE DEPLOYING DEVISE
    resources :signups, controller: "challenge_signups", only: [:index]
    resources :skins, only: [:index]
    resources :stats, only: [:index]
    resources :subscriptions, only: [:index, :create, :destroy]
    resources :tag_sets, controller: "owned_tag_sets", only: [:index]

    resources :works do
      collection do
        get :drafts
        get :collected
        get :show_multiple
        post :edit_multiple
        put :update_multiple
        post :delete_multiple
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
      get :confirm_delete
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
        get :confirm_delete
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
      collection do
        get :unreviewed
        put :review_all
      end
    end
    resources :kudos, only: [:index]
    resources :links, controller: "work_links", only: [:index]
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
      get :fetch
    end
    resources :bookmarks
    resources :related_works
  end

  resources :related_works
  resources :serial_works
  resources :series do
    member do
      get :confirm_delete
      get :manage
      post :update_positions
    end
    resources :bookmarks
  end

  #### COLLECTIONS ####

  resources :gifts, only: [:index]  do
    member do
      post :toggle_rejected
    end
  end

  resources :prompts
  resources :collections do
    collection do
      get :list_challenges
      get :list_ge_challenges
      get :list_pm_challenges
    end
    member do
      get :confirm_delete
    end
    resource :profile, controller: "collection_profile"
    resources :collections
    resources :works
    resources :gifts
    resources :bookmarks
    resources :media
    resources :fandoms
    resources :people
    resources :prompts
    resources :tags do
      resources :works
    end
    resources :participants, controller: "collection_participants" do
      collection do
        get :add
        get :join
      end
    end
    resources :items, controller: "collection_items" do
      collection do
        put :update_multiple
      end
    end
    resources :signups, controller: "challenge_signups" do
      collection do
        get :summary
      end
      member do
        get :confirm_delete
      end
    end
    resources :assignments, controller: "challenge_assignments", except: [:new, :edit, :update] do
      collection do
        get :generate
        put :set
        get :purge
        get :send_out
        put :update_multiple
        get :default_all
      end
      member do
        get :undefault
        get :cover_default
        get :uncover_default
      end
    end
    resources :claims, controller: "challenge_claims" do
      collection do
        put :set
        get :purge
      end
    end
    resources :potential_matches do
      collection do
        get :generate
        get :cancel_generate
        get :regenerate_for_signup
      end
    end
    resources :requests, controller: "challenge_requests"
    # challenge types
    resource :gift_exchange, controller: 'challenge/gift_exchange'
    resource :prompt_meme, controller: 'challenge/prompt_meme'
  end

  #### I18N ####

  # should stay below the main works mapping
  resources :languages do
    resources :works
    resources :admin_posts
  end
  resources :locales do
    collection do
      get :set
    end
  end

  #### API ####

  namespace :api do
    namespace :v1 do
      resources :bookmarks, only: [:create], defaults: { format: :json }
      resources :works, only: [:create], defaults: { format: :json }
      match 'bookmarks/import', to: 'bookmarks#create', via: :post
      match 'import', to: 'works#create', via: :post
      match 'works/import', to: 'works#create', via: :post
      match 'works/urls', to: 'works#batch_urls', via: :post
    end
  end

  #### MISC ####

  resources :comments do
    member do
      put :approve
      put :reject
      put :review
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
    member do
      get :confirm_delete
    end
    resources :collection_items
  end

  resources :kudos, only: [:create]

  resources :skins do
    member do
      get :preview
      get :set
    end
    collection do
      get :unset
    end
  end
  resources :known_issues
  resources :archive_faqs, path: "faq" do
    member do
      get :confirm_delete
    end
    collection do
      get :manage
      post :update_positions
    end
  end
  resources :wrangling_guidelines do
    member do
      get :confirm_delete
    end
    collection do
      get :manage
      post :reorder
    end
  end
  
  resource :redirect, controller: "redirect", only: [:show] do
    member do
      get :do_redirect
    end
  end

  resources :abuse_reports, only: [:new, :create] 
  resources :external_authors do
    resources :external_author_names
  end
  resources :orphans, only: [:index, :new, :create] do
    collection do
      get :about
    end
  end

  match 'search' => 'works#search'
  match 'support' => 'feedbacks#create', as: 'feedbacks', via: [:post]
  match 'support' => 'feedbacks#new', as: 'new_feedback_report', via: [:get]
  match 'tos' => 'home#tos'
  match 'tos_faq' => 'home#tos_faq'
  match 'unicorn_test' => 'home#unicorn_test'
  match 'dmca' => 'home#dmca'
  match 'diversity' => 'home#diversity'
  match 'site_map' => 'home#site_map'
  match 'site_pages' => 'home#site_pages'
  match 'first_login_help' => 'home#first_login_help'
  match 'delete_confirmation' => 'users#delete_confirmation'
  match 'activate/:id' => 'users#activate', as: 'activate'
  match 'devmode' => 'devmode#index'
  match 'donate' => 'home#donate'
  match 'lost_cookie' => 'home#lost_cookie'
  match 'about' => 'home#about'
  match 'menu/browse' => 'menu#browse'
  match 'menu/fandoms' => 'menu#fandoms'
  match 'menu/search' => 'menu#search'
  match 'menu/about' => 'menu#about'

  # The priority is based upon order of creation:
  # first created -> highest priority.
  root to: 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
