MachovyRails::Application.routes.draw do
  root :to => 'front_grid#index'

  # mounted gems
  mount Ckeditor::Engine => '/ckeditor' 
  mount RailsAdmin::Engine => '/Radmin', :as => 'rails_admin'

  # Third party authentication
  # Use a custom controller to support different kinds of users
  devise_for :users, :controllers => { :registrations => 'registrations' }
  
  # Add a user admin action (not part of devise)
  resources :users, :only => [:manage] do
    get 'manage', :on => :collection
  end
  
  # Resources
  resources :blog_posts
  resources :categories
  resources :curators

  resources :metros
  resources :positions
  resources :promotions do 
    member do
      get 'order'
      get 'show_logs'
      put 'accept_edits'
      put 'reject_edits'
    end
  end
  resources :promotion_images
  resources :roles
  resources :videos

  namespace :merchant do
    resources :orders
    resources :vendors do
      member do
        get 'payments'
        get 'dashboard'
        get 'reports'
      end
    end
    resources :vouchers do
      member do
        put :redeem
        get :generate_qrcode
      end
      
      collection do
        put :search
      end
    end
  end
  
  # Need an admin namespace?
  
  match "/deals" => "front_grid#deals"

  # Static pages
  match "/SiteAdmin" => "static_pages#admin_index"
  match "/about" => "static_pages#about"
  match "/front_grid_manage" => "front_grid#manage"
  match "/affiliate_url" => "ajax#affiliate_url"
  
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
