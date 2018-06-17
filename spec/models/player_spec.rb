# == Schema Information
#
# Table name: players
#
#  id                              :integer          not null, primary key
#  first_name                      :string
#  last_name                       :string
#  squad_number                    :integer
#  team_code                       :integer
#  photo                           :string
#  web_name                        :string
#  status                          :string
#  code                            :integer
#  news                            :string
#  now_cost                        :integer
#  chance_of_playing_this_round    :integer
#  chance_of_playing_next_round    :integer
#  value_form                      :decimal(, )
#  value_season                    :decimal(, )
#  cost_change_start               :integer
#  cost_change_event               :integer
#  cost_change_start_fall          :integer
#  cost_change_event_fall          :integer
#  in_dreamteam                    :boolean
#  dreamteam_count                 :integer
#  selected_by_percent             :decimal(, )
#  form                            :decimal(, )
#  transfers_out                   :integer
#  transfers_in                    :integer
#  transfers_out_event             :integer
#  transfers_in_event              :integer
#  loans_in                        :integer
#  loans_out                       :integer
#  loaned_in                       :integer
#  loaned_out                      :integer
#  total_points                    :integer
#  event_points                    :integer
#  points_per_game                 :decimal(, )
#  ep_this                         :decimal(, )
#  ep_next                         :decimal(, )
#  special                         :boolean
#  minutes                         :integer
#  goals_scored                    :integer
#  assists                         :integer
#  clean_sheets                    :integer
#  goals_conceded                  :integer
#  own_goals                       :integer
#  penalties_saved                 :integer
#  penalties_missed                :integer
#  yellow_cards                    :integer
#  red_cards                       :integer
#  saves                           :integer
#  bonus                           :integer
#  bps                             :integer
#  influence                       :decimal(, )
#  creativity                      :decimal(, )
#  threat                          :decimal(, )
#  ict_index                       :decimal(, )
#  open_play_crosses               :integer
#  big_chances_created             :integer
#  clearances_blocks_interceptions :integer
#  recoveries                      :integer
#  key_passes                      :integer
#  tackles                         :integer
#  winning_goals                   :integer
#  dribbles                        :integer
#  fouls                           :integer
#  errors_leading_to_goal          :integer
#  big_chances_missed              :integer
#  offside                         :integer
#  attempted_passes                :integer
#  target_missed                   :integer
#  ea_index                        :integer
#  player_fixture_histories        :jsonb
#  player_past_histories           :jsonb
#  position_id                     :integer
#  team_id                         :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'rails_helper'

RSpec.describe Player, type: :model do
  it 'requires a unique code' do
    player = FactoryBot.create(:player, :fwd)

    expect(FactoryBot.build_stubbed(:player, :fwd, code: player.code)).not_to be_valid
  end

  it 'has valid scopes' do
    forward = FactoryBot.create(:player, :fwd)
    midfielder = FactoryBot.create(:player, :mid)
    defender = FactoryBot.create(:player, :def)
    goalkeeper = FactoryBot.create(:player, :gkp)

    expect(Player.forwards).to contain_exactly(forward)
    expect(Player.midfielders).to contain_exactly(midfielder)
    expect(Player.defenders).to contain_exactly(defender)
    expect(Player.goalkeepers).to contain_exactly(goalkeeper)
  end

  it '#player_fixture_histories' do
    round = FactoryBot.build_stubbed(:round)
    fixture = FactoryBot.build_stubbed(:fixture, round: round)
    minutes = 80
    bps = 15
    was_home = true

    player = FactoryBot.build_stubbed(
      :player,
      :fwd,
      :player_fixture_histories,
      round: round,
      fixture: fixture,
      was_home: was_home,
      minutes: minutes,
      bps: bps,
    )

    player_fixture_history = player.player_fixture_histories.first

    expect(player.team).to eq(fixture.home_team)
    expect(player_fixture_history["round"]).to eq(round.id)
    expect(player_fixture_history["fixture"]).to eq(fixture.id)
    expect(player_fixture_history["was_home"]).to eq(was_home)
    expect(player_fixture_history["minutes"]).to eq(minutes)
    expect(player_fixture_history["bps"]).to eq(bps)

    binding.pry
  end
end
