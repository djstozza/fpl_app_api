Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'api_constraints'
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => "/cable"

  namespace :api do
    namespace :v1 do
      resources :teams, only: [:index, :show]
      resources :rounds, only: :index
      resources :round, only: :index
      resources :players, only: [:index, :show]
      resources :fixtures
    end
  end
end

# Rails.application.routes.draw do
#   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
#   require 'api_constraints'
#
#   namespace :api, defaults: { format: :json }, constraints: { subdomain: 'api' }, path: '/' do
#     scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
#       resources :teams
#       resources :rounds
#       resources :players
#       resources :fixtures
#     end
#   end
# end
