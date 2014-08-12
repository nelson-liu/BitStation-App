Rails.application.routes.draw do
  get 'search_suggestions/user/:query', to: 'search_suggestions#user'

  get 'users/link_coinbase_account', as: :link_coinbase_account
  get 'users/confirm_coinbase_account'
  get 'users/unlink_coinbase_account', as: :unlink_coinbase_account
  get 'users/access_qrcode', as: :access_qrcode
  get 'users/revoke_access_code', as: :revoke_access_code

  get 'sessions/new', as: :sign_in
  get 'sessions/destroy', as: :sign_out
  get 'sessions/authenticate'
  get 'sessions/fail'
  get 'sessions/oauth', as: :oauth

  post 'transactions/transact', as: :transact
  post 'transactions/request_bitcoin', as: :request_bitcoin
  get 'transactions/history'
  get 'transactions/exchange'

  match '/dashboard', to: 'dashboard#dashboard', via: :get, as: :dashboard
  get 'dashboard/account_summary'
  get 'dashboard/transfer'
  get 'dashboard/address_book'
  get 'dashboard/address_book_detailed'
  get 'dashboard/transaction_history'
  get 'dashboard/transaction_details'
  get 'dashboard/transaction_history_detailed'
  get 'dashboard/exchange_currencies'
  get 'dashboard/request_bitcoin'
  get 'dashboard/overview'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to => 'static_pages#homepage'

  match '/about', to: 'static_pages#about', via: :get, as: :about
  match '/security', to: 'static_pages#security', via: :get, as: :security
  match '/faq', to: 'static_pages#faq', via: :get, as: :faq
  match '/team', to: 'static_pages#team', via: :get, as: :team
  match '/privacy', to: 'static_pages#privacy', via: :get, as: :privacy

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
