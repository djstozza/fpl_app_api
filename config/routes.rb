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

      resources :rounds, only: [:index]

      resources :round, only: [:index]

      resources :positions, only: [:index]

      resources :leagues, except: [:destroy] do
        resources :draft_picks,
                  only: [:index, :update],
                  except: [:destroy],
                  param: :draft_pick_id,
                  controller: 'leagues/draft_picks'

        resources :fpl_teams, only: [:update], param: :fpl_team_id, controller: 'leagues/fpl_teams'
        resources :unpicked_players, only: [:index], controller: 'leagues/unpicked_players'

        member do
          get 'edit'
        end

        collection do
          resource :join, only: [:create], to: 'leagues/join#create'
        end
      end

      resources :fpl_teams, except: [:create, :destroy] do
        resources :fpl_team_lists, param: :fpl_team_list_id, only: [:index, :show, :update]
      end

      resources :list_positions, param: :list_position_id, only: [:show, :update]

      resources :players, only: [:index, :show]

      resources :profile, only: [:index]

      resources :trades, only: [:create]

      resources :inter_team_trade_groups, except: [:index], param: :inter_team_trade_group_id
      resources :inter_team_trades

      mount_devise_token_auth_for 'User', at: 'auth',  controllers: {
        registrations: 'users/registrations',
      }

      put '/leagues/:league_id/generate_pick_numbers', to: 'leagues/generate_pick_numbers#update'
      post '/leagues/:league_id/create_draft', to: 'leagues/create_draft#create'

      get '/fpl_teams/:fpl_team_id/waiver_picks', to: 'fpl_teams/waiver_picks#index'
      post '/fpl_team_lists/:fpl_team_list_id/waiver_picks', to: 'fpl_team_lists/waiver_picks#create'
      put '/fpl_team_lists/:fpl_team_list_id/waiver_picks/:waiver_pick_id', to: 'fpl_team_lists/waiver_picks#update'
      delete '/fpl_team_lists/:fpl_team_list_id/waiver_picks/:waiver_pick_id',
        to: 'fpl_team_lists/waiver_picks#destroy'

      get '/fpl_teams/:fpl_team_id/out_players', to: 'out_players#index'
      get '/fpl_teams/:fpl_team_id/all_tradeable_players', to: 'all_tradeable_players#index'
      get '/fpl_teams/:fpl_team_id/inter_team_trade_groups', to: 'inter_team_trade_groups#index'
    end
  end
end
