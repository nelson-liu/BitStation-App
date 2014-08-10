Rails.application.routes.draw do
  get 'users/link_coinbase_account'
  get 'users/confirm_coinbase_account'
  get 'users/unlink_coinbase_account'

  get 'sessions/new'
  get 'sessions/destroy'
  get 'sessions/authenticate'
  get 'sessions/fail'
  get 'sessions/oauth'

  get 'transaction/transfer'
  get 'transaction/history'
  get 'transaction/exchange'

  get 'dashboard/dashboard'
  get 'dashboard/overview'

  get 'static_pages/homepage'

  get 'static_pages/about'

  get 'static_pages/security'

  get 'static_pages/faq'

  get 'static_pages/team'

  get 'static_pages/privacy'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to => 'static_pages#homepage'

  match '/about', to: 'static_pages#about', via: [:get, :post]

  match '/security', to: 'static_pages#security', via: [:get, :post]

  match '/faq', to: 'static_pages#faq', via: [:get, :post]

  match '/team', to: 'static_pages#team', via: [:get, :post]

  match '/privacy', to: 'static_pages#privacy', via: [:get, :post]

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
