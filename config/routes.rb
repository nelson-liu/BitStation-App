Rails.application.routes.draw do
  get 'comments/index'

  get 'comments/new'

  get 'comments/create'

  get 'transfers/index'

  get 'search_suggestions/user/:query', to: 'search_suggestions#user'

  get 'users/require_coinbase_account', as: :require_coinbase_account
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

  match '/dashboard', to: 'dashboard#dashboard', via: :get, as: :dashboard
  get 'dashboard/account_summary'
  get 'dashboard/transfer'
  get 'dashboard/buy_sell_bitcoin'
  get 'transfers/get_price'
  post 'transfers/create'
  get 'dashboard/access_qrcode_details'
  get 'dashboard/bitstation_feed'

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

  resources :transactions, only: [:create, :index, :show] do
    resources :comments, only: [:index, :new, :create, :destroy] do
    end

    member do
      post 'annotate'
    end
  end

  resources :transfers, only: [:create] do
  end

  resources :money_requests, path: 'requests', only: [:show, :index, :create] do
    member do
      post 'pay'
      post 'deny'
      post 'resend'
      post 'cancel'
    end
  end

  resources :contacts, only: [:create, :index, :show, :new, :destroy, :update] do
    collection do
      post 'import', as: :import
    end
  end

  resources :activities, only: [:index] do
  end
end
