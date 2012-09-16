MachovyRails::Application.routes.draw do
  resources :blog_posts

  resources :curators

  devise_for :users
  mount RailsAdmin::Engine => '/Radmin', :as => 'rails_admin'

  resources :roles
  resources :vendors
  resources :metros
  resources :promotion_images
  resources :vouchers
  resources :videos
  resources :categories
  resources :orders
  resources :promotions do 
    member do
      get 'order'
    end
  end

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
  get "membersarea/show"
  get "about/show"
  get "front_grid/index"

  root :to => 'front_grid#index', as: 'frontgrid'
  
  match "/about" => "about#show"
  match "/videos" => "videos#show"
  match "/video" => "video#show"
  match "/member" => "membersarea#show"
  match "/merchants" => "merchantsignup#show"
  match "/SiteAdmin" => "site_admin#index"
  
  
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
