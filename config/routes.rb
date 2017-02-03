Rails.application.routes.draw do
  mount Spotlight::Resources::Iiif::Engine, at: 'spotlight_resources_iiif'
  mount Blacklight::Oembed::Engine, at: 'oembed'

  root to: 'spotlight/exhibits#index'
  resources :exhibits, path: '/spotlight', only: [:create, :destroy]

  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'

  # root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [:passwords, :registration]
  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    get 'users/auth/cas', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: "new_user_session"
  end

  # Dynamic robots.txt
  get '/robots.:format' => 'pages#robots'
  mount Riiif::Engine => '/images', as: 'riiif'
end
