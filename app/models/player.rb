# == Schema Information
#
# Table name: players
#
#  id                           :integer          not null, primary key
#  first_name                   :string
#  last_name                    :string
#  squad_number                 :integer
#  team_code                    :integer
#  photo                        :string
#  web_name                     :string
#  status                       :string
#  code                         :integer
#  news                         :string
#  now_cost                     :integer
#  chance_of_playing_this_round :integer
#  chance_of_playing_next_round :integer
#  value_form                   :decimal(, )
#  value_season                 :decimal(, )
#  cost_change_start            :integer
#  cost_change_event            :integer
#  cost_change_start_fall       :integer
#  cost_change_event_fall       :integer
#  in_dreamteam                 :boolean
#  dreamteam_count              :integer
#  selected_by_percent          :decimal(, )
#  form                         :decimal(, )
#  transfers_out                :integer
#  transfers_in                 :integer
#  transfers_out_event          :integer
#  transfers_in_event           :integer
#  loans_in                     :integer
#  loans_out                    :integer
#  loaned_in                    :integer
#  loaned_out                   :integer
#  total_points                 :integer
#  event_points                 :integer
#  points_per_game              :decimal(, )
#  ep_this                      :decimal(, )
#  ep_next                      :decimal(, )
#  special                      :boolean
#  minutes                      :integer
#  goals_scored                 :integer
#  assists                      :integer
#  clean_sheets                 :integer
#  goals_conceded               :integer
#  own_goals                    :integer
#  penalties_saved              :integer
#  penalties_missed             :integer
#  yellow_cards                 :integer
#  red_cards                    :integer
#  saves                        :integer
#  bonus                        :integer
#  bps                          :integer
#  influence                    :decimal(, )
#  creativity                   :decimal(, )
#  threat                       :decimal(, )
#  ict_index                    :decimal(, )
#  ea_index                     :integer
#  player_fixture_histories     :jsonb
#  player_past_histories        :jsonb
#  position_id                  :integer
#  team_id                      :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class Player < ApplicationRecord
end
