Rails.application.routes.draw do
  resources :fpl_team_lists
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

      resources :positions, only: :index

      resources :leagues, except: :destroy do
        resources :draft_picks,
                  only: [:index, :update],
                  except: :destroy,
                  param: :draft_pick_id,
                  controller: 'leagues/draft_picks'

        resources :fpl_teams, only: :update, param: :fpl_team_id, controller: 'leagues/fpl_teams'

        member do
          get 'edit'
        end

        collection do
          resource :join, only: :create, to: 'leagues/join#create'
        end
      end

      resources :fpl_teams, except: :destroy

      resources :fpl_team_lists

      resources :players, only: [:index, :show]

      resources :profile, only: [:index]

      resources :fixtures

      mount_devise_token_auth_for 'User', at: 'auth',  controllers: {
        registrations: 'users/registrations',
      }

      put '/leagues/:league_id/generate_pick_numbers', to: 'leagues/generate_pick_numbers#update'
      post '/leagues/:league_id/create_draft', to: 'leagues/create_draft#create'
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
