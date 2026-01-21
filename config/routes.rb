# frozen_string_literal: true

Rails.application.routes.draw do
  mount HealthMonitor::Engine, at: "/"
  mount Blacklight::Oembed::Engine, at: "oembed"

  require "sidekiq/pro/web"
  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [:passwords, :registration]
  devise_scope :user do
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
    get "users/auth/cas", to: "users/omniauth_authorize#passthru", defaults: { provider: :cas }, as: "new_user_session"
  end

  mount Blacklight::Engine => "/"

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :bookmarks do
    concerns :exportable

    collection do
      delete "clear"
      get "csv"
    end
  end

  root to: "spotlight/exhibits#index"
  resource :site, only: [:edit, :update], controller: "spotlight/sites" do
    collection do
      get "/tags", to: "sites#tags"
    end
  end
  resources :exhibits, path: "/", only: [:create, :update, :destroy]

  # Override the Spotlight bulk actions routes to use local BulkActionsController
  post "/:exhibit_id/bulk_actions/change_visibility", as: "change_visibility_exhibit_bulk_actions", to: "bulk_actions#change_visibility"
  post "/:exhibit_id/bulk_actions/add_tags", as: "add_tags_exhibit_bulk_actions", to: "bulk_actions#add_tags"
  post "/:exhibit_id/bulk_actions/remove_tags", as: "remove_tags_exhibit_bulk_actions", to: "bulk_actions#remove_tags"

  match "/:exhibit_id/metadata_configuration", to: "pomegranate/metadata_configurations#update", via: [:patch, :put]

  # root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: "catalog", path: "/catalog", controller: "catalog" do
    concerns :searchable
  end

  match "/404", to: "pages#not_found", via: :all
  match "/500", to: "pages#internal_server_error", via: :all
  get "/viewers", to: "pages#viewers", as: "viewers_page"
  # Dynamic robots.txt
  get "/robots.:format" => "pages#robots"
  mount Spotlight::Engine, at: "/"

  resources :solr_documents, only: [:show], path: "/catalog", controller: "catalog" do
    concerns :exportable
  end

  mount Riiif::Engine => "/images", as: "riiif"
end
