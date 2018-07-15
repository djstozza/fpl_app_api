require 'rails_helper'

RSpec.describe Teams::Populate do
  it "creates a team" do
    response_hash = {
      "id" => 1,
      "name" => "Arsenal",
      "code" => 3,
      "short_name" => "ARS",
      "unavailable" => false,
      "strength" => 4,
      "position" => 0,
      "played" => 0,
      "win" => 1,
      "loss" => 5,
      "draw" => 0,
      "points" => 3,
      "form" => nil,
      "link_url" => "",
      "strength_overall_home" => 1250,
      "strength_overall_away" => 1320,
      "strength_attack_home" => 1240,
      "strength_attack_away" => 1290,
      "strength_defence_home" => 1260,
      "strength_defence_away" => 1320,
      "team_division" => 1,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    described_class.run!

    team = Team.first

    expect(team.name).to eq(response_hash['name'])
    expect(team.short_name).to eq(response_hash['short_name'])
    expect(team.wins).to eq(response_hash['win'])
    expect(team.losses).to eq(response_hash['loss'])
    expect(team.draws).to eq(response_hash['draw'])
  end

  it "updates an existing team" do
    team = FactoryBot.create(:team)

    response_hash = {
      "id" => team.id,
      "name" => team.name,
      "code" => team.code,
      "short_name" => team.short_name,
      "unavailable" => false,
      "strength" => 4,
      "position" => 0,
      "played" => 0,
      "win" => 1,
      "loss" => 5,
      "draw" => 0,
      "points" => 3,
      "form" => nil,
      "link_url" => "",
      "strength_overall_home" => 1250,
      "strength_overall_away" => 1320,
      "strength_attack_home" => 1240,
      "strength_attack_away" => 1290,
      "strength_defence_home" => 1260,
      "strength_defence_away" => 1320,
      "team_division" => 1,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    described_class.run!

    expect(team.reload.wins).to eq(response_hash['win'])
    expect(team.losses).to eq(response_hash['loss'])
    expect(team.draws).to eq(response_hash['draw'])
  end
end
