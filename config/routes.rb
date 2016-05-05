Rails.application.routes.draw do
  mount Spotlight::Resources::Iiif::Engine, at: 'spotlight_resources_iiif'
  mount Blacklight::Oembed::Engine, at: 'oembed'
  root to: 'spotlight/exhibits#index'
  resources :exhibits, path: '/spotlight', only: [:create]
  mount Spotlight::Engine, at: 'spotlight'
  # root to: "catalog#index" # replaced by spotlight root path
  blacklight_for :catalog
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [:passwords, :registration]
  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    get 'users/auth/cas', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: "new_user_session"
  end

  # Dynamic robots.txt
  get '/robots.:format' => 'pages#robots'
end
