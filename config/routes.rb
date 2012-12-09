MachovyRails::Application.routes.draw do
  root :to => 'front_grid#index'

  # mounted gems
  mount Ckeditor::Engine => '/ckeditor' 
  mount RailsAdmin::Engine => '/Radmin', :as => 'rails_admin'

  # Third party authentication
  # Use custom controllers to support different kinds of users
  devise_for :users, :controllers => { :registrations => 'registrations', 
                                       :confirmations => 'confirmations' }
  
  # Add a user admin action (not part of devise)
  resources :users, :only => [:manage] do    
    member do
      get 'survey'
      put 'feedback'
      get 'edit_profile'
      put 'update_profile'
      put 'promote'
    end

    get 'manage', :on => :collection
  end
  
  # Resources
  resources :blog_posts do
    put 'update_weight', :on => :member
    put 'rebalance', :on => :collection
  end
  
  resources :categories
  resources :curators

  resources :ideas, :only => [:index, :show, :create, :destroy]
  resources :ratings, :only => [:create]
  
  resources :metros
  resources :positions
  resources :promotions do 
    member do
      get 'order'
      get 'show_logs'
      put 'accept_edits'
      put 'reject_edits'
      put 'update_weight'
    end
    
    collection do
      get 'manage'
      put 'rebalance'
      get 'affiliates'
    end
  end
  resources :promotion_images
  resources :roles
  resources :videos
  resources :stripe_logs, :only => [:index, :show]
  resources :macho_bucks, :only => [:index, :create] do
    collection do
      get 'about'
      put 'search'
    end
  end
  
  namespace :merchant do
    resources :orders, :except => [:index, :edit, :update]
    resources :vendors do
      member do
        get 'reports'
        get 'show_payments'
      end
    end
    resources :payments, :only => [:new, :create]
    resources :vouchers, :only => [:index, :show] do
      member do
        get :redeem
        put :redeem_admin
        get :generate_qrcode
      end
      
      collection do
        put :search
      end
    end
  end
  
  # Filtering
  match "/deals" => "ajax#deals"
  # Can't call this /metro because I already have a :metro resource, and it would conflict with show
  match "/metro_filter" => "ajax#metro"
  match "/category" => "ajax#category"

  # Affiliate processing
  match "/affiliate_url" => "ajax#affiliate_url"
 
  # Static pages
  match "/site_admin" => "static_pages#admin_index"
  match "/about" => "static_pages#about"
	match "/get_featured" => "static_pages#get_featured"
	match "/feedback" => "static_pages#feedback"
  match "/make_comment" => "static_pages#make_comment", :via => :put
  match "/faq" => "static_pages#faq"
  
  # MailChimp integration test
  match "/mailing" => "static_pages#mailing"
 
  # Stripe web hooks
  match "/test_stripe" => "stripe_logs#test", :via => :post
  match "/live_stripe" => "stripe_logs#live", :via => :post
     
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)' 
end
