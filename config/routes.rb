MachovyRails::Application.routes.draw do
  # Home page
  # as defines frontgrid_path and front_grid_index_path to "/"
  root :to => 'front_grid#index', as: 'frontgrid'

  # mounted gems
  mount Ckeditor::Engine => '/ckeditor' 
  mount RailsAdmin::Engine => '/Radmin', :as => 'rails_admin'

  # Third party authentication
  devise_for :users

  # Resources
  resources :blog_posts
  resources :categories
  resources :curators
  resources :metros
  resources :promotions do 
    member do
      get 'order'
    end
    
    collection do
      get 'deals'
    end
   end
  resources :promotion_images
  resources :roles
  resources :videos

  namespace :merchant do
    resources :orders
    resources :vendors
    resources :vouchers
  end
  
  # Need an admin namespace?
  
  match "/deals" => "promotions#deals"
  match "/about" => "static_pages#about"

#  get "deals/index"
=begin
  get "site_admin/add_ad"
  get "site_admin/add_deal"
  get "site_admin/add_affiliate"
  get "site_admin/add_vendor"
  get "site_admin/add_metro"
  get "site_admin/front_page"
  get "site_admin/user_admin"
  get "site_admin/merchant_admin"
  get "site_admin/reports"
  get "site_admin/index"
=end
#  get "membersarea/show"
#  get "about/show"
#  get "front_grid/index"

# Confusing! What is the intent here?
#  match "/videos" => "videos#show"
#  match "/video" => "video#show"
#  match "/member" => "membersarea#show"
# ? use normal resource: /merchants/vendors#new or the like; new_merchant_vendor_path 
#  match "/merchants" => "merchantsignup#show"

# Don't understand this yet.
#  match "/SiteAdmin" => "site_admin#index"
  
  # Static pages
#  match "/about" => "about#show"
   
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
