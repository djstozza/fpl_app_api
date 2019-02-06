require 'rails_helper'

RSpec.describe Fixtures::Populate do
  it "creates a flixture - fixte not started" do
    round = FactoryBot.create(:round)
    team_1 = FactoryBot.create(:team)
    team_2 = FactoryBot.create(:team)

    response_hash = {
      "id" => 1,
      "kickoff_time_formatted" => "12 Aug 16:00",
      "started" => false,
      "event_day" => 3,
      "deadline_time" => "2018-08-10T18:00:00Z",
      "deadline_time_formatted" => "10 Aug 19:00",
      "stats" => [],
      "team_h_difficulty" => 5,
      "team_a_difficulty" => 4,
      "code" => 987593,
      "kickoff_time" => "2018-08-12T15:00:00Z",
      "team_h_score" => nil,
      "team_a_score" => nil,
      "finished" => false,
      "minutes" => 0,
      "provisional_start_time" => false,
      "finished_provisional" => false,
      "event" => round.id,
      "team_a" => team_2.id,
      "team_h" => team_1.id,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    described_class.run!

    fixture = Fixture.first

    expect(fixture.round).to eq(round)
    expect(fixture.home_team).to eq(team_1)
    expect(fixture.away_team).to eq(team_2)
    expect(fixture.started).to be_falsy
    expect(fixture.stats).to be_nil
  end

  it "creates a fixture - fixture started" do
    fixture = FactoryBot.create(:fixture)

    player_1 = FactoryBot.create(:player, team: fixture.home_team)
    player_2 = FactoryBot.create(:player, team: fixture.home_team)
    player_3 = FactoryBot.create(:player, team: fixture.away_team)
    player_4 = FactoryBot.create(:player, team: fixture.away_team)
    player_5 = FactoryBot.create(:player, team: fixture.away_team)

    response_hash = {
      "id" => fixture.id,
      "kickoff_time_formatted" => "12 Aug 16:00",
      "started" => true,
      "event_day" => 3,
      "deadline_time" => "2018-08-10T18:00:00Z",
      "deadline_time_formatted" => "10 Aug 19:00",
      "stats" => [
        {
          "goals_scored" => {
            "h" => [{ "value" => 1, "element" => player_1.id }],
            "a" => [{ "value" => 2, "element" => player_3.id }],
          },
          "assists" => {
            "h" => [{ "value" => 1, "element" => player_2.id }],
            "a" => [{ "value" => 1, "element" => player_4.id }],
          },
          "yellow_cards" => {
            "h" => [{ "value" => 1, "element" => player_1.id }],
          },
          "saves" => {
            "a" => [{ "value" => 1, "element" => player_5.id }],
          },
          "bonus" => {
            "a" => [{ "value" => 3, "element" => player_3.id }, { "value" => 1, "element" => player_4.id }],
            "h" => [{ "value" => 2, "element" => player_2.id }],
          },
          "bps" => {
            "a" => [
              { "value" => 5, "element" => player_3.id },
              { "value" => 3, "element" => player_4.id },
              { "value" => 1, "element" => player_5.id },
            ],
            "h" => [
              { "value" => 2, "element" => player_2.id },
              { "value" => 4, "element" => player_1.id },
            ],
          }
        }
      ],
      "team_h_difficulty" => 5,
      "team_a_difficulty" => 4,
      "code" => fixture.code,
      "kickoff_time" => "2018-08-12T15:00:00Z",
      "team_h_score" => 2,
      "team_a_score" => 1,
      "finished" => false,
      "minutes" => 80,
      "provisional_start_time" => false,
      "finished_provisional" => false,
      "event" => fixture.round_id,
      "team_a" => fixture.team_a_id,
      "team_h" => fixture.team_h_id,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    described_class.run!

    expect(fixture.reload.team_h_score).to eq(response_hash['team_h_score'])
    expect(fixture.team_a_score).to eq(response_hash['team_a_score'])
    expect(fixture.minutes).to eq(response_hash['minutes'])

    stats = fixture.stats

    expect(stats.dig('goals_scored')).to eq(
      {
        "name" => "Goals Scored",
        "initials" => "GS",
        "away_team" => [{"value" => 2, "player" => { "id" => player_3.id, "last_name" => player_3.last_name } }],
        "home_team" =>[{ "value" => 1, "player" => { "id" => player_1.id, "last_name" => player_1.last_name } }]
      },
    )

    expect(stats.dig('assists')).to eq(
      {
        "name"=>"Assists",
        "initials" => "A",
        "away_team" => [{ "value" => 1, "player" => { "id" => player_4.id, "last_name" => player_4.last_name } }],
        "home_team" => [{ "value" => 1, "player" => { "id" => player_2.id, "last_name" => player_2.last_name } }],
      },
    )

    expect(stats.dig('saves')).to eq(
      {
        "name" => "Saves",
        "initials" => "S",
        "away_team" => [{ "value" => 1, "player" => { "id" => player_5.id, "last_name" => player_5.last_name } }],
        "home_team" => [],
      },
    )

    expect(stats.dig("yellow_cards")).to eq(
      {
        "name" => "Yellow Cards",
        "initials" => "YC",
        "away_team" => [],
        "home_team" => [{ "value" => 1, "player" => { "id" => player_1.id, "last_name" => player_1.last_name } }]
      },
    )

    expect(stats.dig("own_goals")).to eq(
      { "name" => "Own Goals", "initials" => "OG", "away_team" => [], "home_team" => [] },
    )

    expect(stats.dig("red_cards")).to eq(
     { "name" => "Red Cards", "initials" => "RC", "away_team" => [], "home_team" => [] },
    )

    expect(stats.dig("penalties_saved")).to eq(
      { "name" => "Penalties Saved", "initials" => "PS", "away_team" => [], "home_team" => [] },
    )

    expect(stats.dig("penalties_missed")).to eq(
      { "name" => "Penalties Missed", "initials" => "PM", "away_team" => [], "home_team" => [] },
    )

    expect(stats.dig("bonus")).to eq(
      {
        "name" => "Bonus",
        "initials" => "B",
        "away_team" => [
          { "value" => 3, "player" => { "id" => player_3.id, "last_name" => player_3.last_name } },
          { "value" => 1, "player" => { "id" => player_4.id, "last_name" => player_4.last_name } }],
        "home_team" => [
          { "value" => 2, "player" => { "id" => player_2.id, "last_name" => player_2.last_name } },
        ],
      },
    )

    # Merges home and away team bps into one array ordered by descending value
    expect(stats.dig("bps")).to eq(
      [
        { "value" => 5, "element" => player_3.id },
        { "value" => 4, "element" => player_1.id },
        { "value" => 3, "element" => player_4.id },
        {"value" => 2, "element" => player_2.id },
        {"value" => 1, "element" => player_5.id },
      ],
    )
  end
end
