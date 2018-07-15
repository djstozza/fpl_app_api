require 'rails_helper'

RSpec.describe Players::Populate do
  it "creates a player" do
    team = FactoryBot.create(:team)
    position = Position.find_by(singular_name_short: "FWD")

    response_hash = {
      "id" => 1,
      "photo" => "11334.jpg",
      "web_name" => "Cech",
      "team_code" => team.code,
      "status" => "a",
      "code" => 11334,
      "first_name" => "Petr",
      "second_name" => "Cech",
      "squad_number" => 1,
      "news" => "",
      "now_cost" => 50,
      "news_added" => nil,
      "chance_of_playing_this_round" => 50,
      "chance_of_playing_next_round" => 100,
      "value_form" => "0.0",
      "value_season" => "0.0",
      "cost_change_start" => 0,
      "cost_change_event" => 0,
      "cost_change_start_fall" => 0,
      "cost_change_event_fall" => 0,
      "in_dreamteam" => false,
      "dreamteam_count" => 0,
      "selected_by_percent" => "1.1",
      "form" => "3.5",
      "transfers_out" => 0,
      "transfers_in" => 0,
      "transfers_out_event" => 0,
      "transfers_in_event" => 0,
      "loans_in" => 0,
      "loans_out" => 0,
      "loaned_in" => 0,
      "loaned_out" => 0,
      "total_points" => 124,
      "event_points" => 0,
      "points_per_game" => "3.6",
      "ep_this" => nil,
      "ep_next" => "2.1",
      "special" => false,
      "minutes" => 3039,
      "goals_scored" => 0,
      "assists" => 0,
      "clean_sheets" => 11,
      "goals_conceded" => 48,
      "own_goals" => 0,
      "penalties_saved" => 1,
      "penalties_missed" => 0,
      "yellow_cards" => 1,
      "red_cards" => 0,
      "saves" => 90,
      "bonus" => 7,
      "bps" => 627,
      "influence" => "722.4",
      "creativity" => "0.0",
      "threat" => "0.0",
      "ict_index" => "71.9",
      "ea_index" => 0,
      "element_type" => position.id,
      "team" => team.id,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    expect_to_execute(Players::PopulateHistory)

    described_class.run!

    player = Player.first

    expect(player.team).to eq(team)
    expect(player.position).to eq(position)
    expect(player.photo).to eq(response_hash['photo'])
    expect(player.first_name).to eq(response_hash['first_name'])
    expect(player.last_name).to eq(response_hash['second_name'])
    expect(player.code).to eq(response_hash['code'])

    expect(player.form).to eq(response_hash['form'].to_d)
    expect(player.ict_index).to eq(response_hash['ict_index'].to_d)
    expect(player.chance_of_playing_next_round).to eq(response_hash['chance_of_playing_next_round'])
    expect(player.chance_of_playing_this_round).to eq(response_hash['chance_of_playing_this_round'])

    expect(player.goals_scored).to eq(response_hash['goals_scored'])
    expect(player.assists).to eq(response_hash['assists'])
    expect(player.minutes).to eq(response_hash['minutes'])
    expect(player.clean_sheets).to eq(response_hash['clean_sheets'])
    expect(player.goals_conceded).to eq(response_hash['goals_conceded'])
  end

  it "updates an existing player" do
    player = FactoryBot.create(:player)

    response_hash = {
      "id" => player.id,
      "photo" => "#{player.code}.jpg",
      "web_name" => player.last_name,
      "team_code" => player.team.code,
      "status" => "a",
      "code" => player.code,
      "first_name" => player.first_name,
      "second_name" => player.last_name,
      "squad_number" => 1,
      "news" => "",
      "now_cost" => 50,
      "news_added" => nil,
      "chance_of_playing_this_round" => 50,
      "chance_of_playing_next_round" => 100,
      "value_form" => "0.0",
      "value_season" => "0.0",
      "cost_change_start" => 0,
      "cost_change_event" => 0,
      "cost_change_start_fall" => 0,
      "cost_change_event_fall" => 0,
      "in_dreamteam" => false,
      "dreamteam_count" => 0,
      "selected_by_percent" => "1.1",
      "form" => "3.5",
      "transfers_out" => 0,
      "transfers_in" => 0,
      "transfers_out_event" => 0,
      "transfers_in_event" => 0,
      "loans_in" => 0,
      "loans_out" => 0,
      "loaned_in" => 0,
      "loaned_out" => 0,
      "total_points" => 124,
      "event_points" => 0,
      "points_per_game" => "3.6",
      "ep_this" => nil,
      "ep_next" => "2.1",
      "special" => false,
      "minutes" => 3039,
      "goals_scored" => 0,
      "assists" => 0,
      "clean_sheets" => 11,
      "goals_conceded" => 48,
      "own_goals" => 0,
      "penalties_saved" => 1,
      "penalties_missed" => 0,
      "yellow_cards" => 1,
      "red_cards" => 0,
      "saves" => 90,
      "bonus" => 7,
      "bps" => 627,
      "influence" => "722.4",
      "creativity" => "0.0",
      "threat" => "0.0",
      "ict_index" => "71.9",
      "ea_index" => 0,
      "element_type" => player.position_id,
      "team" => player.team_id,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    expect_to_execute(Players::PopulateHistory)

    described_class.run!

    expect(player.reload.form).to eq(response_hash['form'].to_d)
    expect(player.ict_index).to eq(response_hash['ict_index'].to_d)
    expect(player.chance_of_playing_next_round).to eq(response_hash['chance_of_playing_next_round'])
    expect(player.chance_of_playing_this_round).to eq(response_hash['chance_of_playing_this_round'])

    expect(player.goals_scored).to eq(response_hash['goals_scored'])
    expect(player.assists).to eq(response_hash['assists'])
    expect(player.minutes).to eq(response_hash['minutes'])
    expect(player.clean_sheets).to eq(response_hash['clean_sheets'])
    expect(player.goals_conceded).to eq(response_hash['goals_conceded'])
  end
end
