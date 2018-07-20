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

      resources :current_round, only: [:index]

      resources :positions, only: [:index]

      resources :leagues, except: [:index, :destroy] do
        resources :draft_picks,
          only: [:index, :update],
          except: [:destroy],
          param: :draft_pick_id,
          controller: 'leagues/draft_picks'

        resources :fpl_teams, only: [:index, :update], param: :fpl_team_id, controller: 'leagues/fpl_teams'
        resources :unpicked_players, only: [:index], controller: 'leagues/unpicked_players'
        resources :mini_draft_picks, only: [:index, :create], controller: 'leagues/mini_draft_picks'

        resource :pass_mini_draft_picks, only: [:create], controller: 'leagues/pass_mini_draft_picks'

        resource :generate_fpl_team_draft_pick_numbers,
          only: [:update],
          controller: 'leagues/generate_fpl_team_draft_pick_numbers'

        resource :create_draft, only: [:create], controller: 'leagues/create_draft'

        member do
          get 'edit'
        end

        collection do
          resource :join, only: [:create], to: 'leagues/join#create'
        end
      end

      resources :fpl_teams, except: [:create, :destroy] do
        resources :inter_team_trade_groups, only: [:index]
      end

      resources :fpl_team_lists, only: [:show] do
        resources :waiver_picks,
          param: :waiver_pick_id,
          only: [:create, :update, :destroy],
          controller: 'fpl_team_lists/waiver_picks'

        resources :tradeable_players, only: [:index], controller: 'fpl_team_lists/tradeable_players'
      end

      resources :list_positions, param: :list_position_id, only: [:show, :update]

      resources :players, only: [:index, :show]

      resources :profile, only: [:index]

      resources :trades, only: [:create]

      resources :inter_team_trade_groups, only: [:create, :update], param: :inter_team_trade_group_id

      mount_devise_token_auth_for 'User', at: 'auth',  controllers: {
        registrations: 'users/registrations',
      }
    end
  end
end
