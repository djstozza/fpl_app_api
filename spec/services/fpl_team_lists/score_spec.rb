require 'rails_helper'

RSpec.describe FplTeamLists::Score do
  it 'fixture started no substitutes' do
    fixture = FactoryBot.create(:fixture, started: true, finished: false)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: fixture.round)

    player_1_total_points = 5
    player_1_bps = 15

    fixture_histories_arr_1 = [
      {
        minutes: 80,
        total_points: player_1_total_points,
        was_home: true,
        bps: player_1_bps,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_1 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.home_team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    player_2_total_points = 4
    player_2_bps = 10

    fixture_histories_arr_2 = [
      {
        minutes: 80,
        total_points: player_2_total_points,
        was_home: false,
        bps: player_2_bps,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_2 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_2,
    )

    bps_arr = [
      { "value" => player_1_bps, "element" => player_1.id },
      { "value" => player_2_bps, "element" => player_2.id },
      { "value" => player_2_bps - 1, "element" => player_2.id + 1 },
    ]

    fixture.update(
      stats: {
        bps: bps_arr,
      }
    )

    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :starting,
      :s1,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    expect_any_instance_of(described_class).not_to receive(:valid_substitution)

    described_class.run!(fpl_team_list: fpl_team_list)

    expect(fpl_team_list.list_positions.starting).to contain_exactly(list_position_1)
    expect(fpl_team_list.list_positions.substitutes).to contain_exactly(list_position_2)

    bonus = bps_arr.reverse.index { |h| h['element'] == player_1.id } + 1
    score = player_1_total_points + bonus

    expect(fpl_team_list.total_score).to eq(score)
  end

  it 'fixture finished no substitutes' do
    fixture = FactoryBot.create(:fixture, started: true, finished: true)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: fixture.round)

    player_1_total_points = 5
    player_1_bps = 15

    fixture_histories_arr_1 = [
      {
        minutes: 80,
        total_points: player_1_total_points,
        was_home: true,
        bps: player_1_bps,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_1 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.home_team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    player_2_total_points = 4
    player_2_bps = 10

    fixture_histories_arr_2 = [
      {
        minutes: 80,
        total_points: player_2_total_points,
        was_home: false,
        bps: player_2_bps,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_2 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_2,
    )

    fixture.update(
      stats: {
        bps: [
          { "value" => player_1_bps, "element" => player_1.id },
          { "value" => player_2_bps, "element" => player_2.id },
          { "value" => player_2_bps - 1, "element" => player_2.id + 1 },
        ]
      }
    )

    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :s1,
      :fwd,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    expect_any_instance_of(described_class).not_to receive(:valid_substitution)

    described_class.run!(fpl_team_list: fpl_team_list)

    expect(fpl_team_list.list_positions.starting).to contain_exactly(list_position_1)
    expect(fpl_team_list.list_positions.substitutes).to contain_exactly(list_position_2)
    expect(fpl_team_list.total_score).to eq(player_1_total_points)
  end

  it 'no substitution as fixture not started' do
    round = FactoryBot.create(:round)
    team = FactoryBot.create(:team)
    fixture_1 = FactoryBot.create(:fixture, started: false, finished: false, round: round, home_team: team)
    fixture_2 = FactoryBot.create(:fixture, started: true, finished: true, round: round, away_team: team)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: round)

    fixture_histories_arr_1 = [
      {
        minutes: 0,
        total_points: 0,
        was_home: true,
        bps: 0,
        round: round,
        fixture: fixture_1,
      },
    ]

    player_1 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    fixture_histories_arr_2 = [
      {
        minutes: 80,
        total_points: 4,
        was_home: false,
        bps: 14,
        round: round,
        fixture: fixture_1,
      }
    ]

    player_2 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture_1.away_team,
      player_fixture_histories_arr: fixture_histories_arr_2,
    )

    fixture_2.update(
      stats: {
        bps: [
          { "value" => Faker::Number.number(2), "element" => Faker::Number.number(2) },
          { "value" => Faker::Number.number(2), "element" => Faker::Number.number(2) },
          { "value" => Faker::Number.number(2), "element" => Faker::Number.number(2) },
        ]
      }
    )


    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :s1,
      :fwd,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    expect_any_instance_of(described_class).not_to receive(:valid_substitution)

    described_class.run!(fpl_team_list: fpl_team_list)

    expect(fpl_team_list.list_positions.starting).to contain_exactly(list_position_1)
    expect(fpl_team_list.list_positions.substitutes).to contain_exactly(list_position_2)
    expect(fpl_team_list.total_score).to eq(0)
  end

  it 'fixture started, player 1 no minutes + player 2 with a bye' do
    fixture = FactoryBot.create(:fixture, started: true, finished: false)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: fixture.round)

    fixture_histories_arr_1 = [
      {
        minutes: 0,
        total_points: 0,
        was_home: true,
        bps: 0,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_1 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.home_team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    # Player 2 has a bye
    player_2 = FactoryBot.create(:player, :fwd)

    player_3_total_points = 5
    player_3_bps = 5

    fixture_histories_arr_3 = [
      {
        minutes: 80,
        total_points: player_3_total_points,
        was_home: false,
        bps: player_3_bps,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_3 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_3,
    )

    player_4_total_points = 4

    fixture_histories_arr_4 = [
      {
        minutes: 80,
        total_points: player_4_total_points,
        was_home: false,
        bps: 0,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_4 = FactoryBot.create(
      :player,
      :mid,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_4,
    )

    bps_arr = [
      { "value" => 10, "element" => Faker::Number.number(5) },
      { "value" => 8, "element" => Faker::Number.number(5) },
      { "value" => player_3_bps, "element" => player_3.id },
    ]

    fixture.update(
      stats: {
        bps: bps_arr
      }
    )

    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    list_position_3 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_3,
      fpl_team_list: fpl_team_list,
    )

    list_position_4 = FactoryBot.create(
      :list_position,
      :s1,
      :mid,
      player: player_4,
      fpl_team_list: fpl_team_list,
    )

    expect_any_instance_of(described_class).to receive(:substitute_starting_field_positions_arr).and_return(
      %w[FWD FWD FWD MID MID MID MID DEF DEF DEF]
    )

    described_class.run!(fpl_team_list: fpl_team_list)

    # List Position 1 is still starting because the fixture hasn't finished yet (still has the potential to play)
    # even though Player 1 hasn't played any minutes yet
    expect(fpl_team_list.list_positions.starting).to contain_exactly(list_position_1, list_position_3, list_position_4)

    # List Position 2 was substituted with List Position 4
    # Player 2 had a bye this Round (no Fixture and hence no player_fixture_history i.e. nil minutes)
    # Player 4 played minutes
    expect(fpl_team_list.list_positions.substitutes).to contain_exactly(list_position_2)

    # Player 3 had one bonus point
    player_3_bonus = bps_arr.reverse.index { |h| h['element'] == player_3.id } + 1

    # Score is made up of Player 3's points and Player 4's points as both of there list positions started
    # Player 1 has not scored any points yet
    score = player_3_total_points + player_3_bonus + player_4_total_points

    expect(fpl_team_list.total_score).to eq(score)
  end

  it 'fixture finished, one starting fwd with no minutes, fwd at s3 is only valid substitution' do
    fixture = FactoryBot.create(:fixture, started: true, finished: true)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: fixture.round)

    fixture_histories_arr_1 = [
      {
        minutes: 0,
        total_points: 0,
        was_home: true,
        bps: 0,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_1 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.home_team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    # Player 2 has a bye
    player_2 = FactoryBot.create(:player, :fwd)

    player_3_total_points = 5
    player_3_bps = 5

    fixture_histories_arr_3 = [
      {
        minutes: 80,
        total_points: player_3_total_points,
        was_home: false,
        bps: player_3_bps,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_3 = FactoryBot.create(
      :player,
      :mid,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_3,
    )

    player_4_total_points = 4

    fixture_histories_arr_4 = [
      {
        minutes: 80,
        total_points: player_4_total_points,
        was_home: false,
        bps: 0,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_4 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_4,
    )

    bps_arr = [
      { "value" => 10, "element" => Faker::Number.number(5) },
      { "value" => 8, "element" => Faker::Number.number(5) },
      { "value" => player_3_bps, "element" => player_3.id },
    ]

    fixture.update(
      stats: {
        bps: bps_arr
      }
    )

    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :s1,
      :fwd,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    list_position_3 = FactoryBot.create(
      :list_position,
      :s2,
      :mid,
      player: player_3,
      fpl_team_list: fpl_team_list,
    )

    list_position_4 = FactoryBot.create(
      :list_position,
      :s3,
      :fwd,
      player: player_4,
      fpl_team_list: fpl_team_list,
    )

    # List Position 1 is substitutable since the Fixture had finished and Player 1 played no minutes
    # List Position 2 could not substitute List Position 1 despite being S1 because Player 2 played nil min (bye)
    # List Position 3 could not substitute List Position 1 despite being S2 because Player 3 is a midfielder and there
    # must always be at least 1 forward in the starting line up
    expect_any_instance_of(described_class).to receive(:substitute_starting_field_positions_arr)
      .and_return(
        %w[MID MID MID MID MID DEF DEF DEF DEF DEF],
      )

    # List Position 4 palyed minutes and therefore could substitute List Position 1 from S3 because S1 and S2 were not
    # valid substitutions
    expect_any_instance_of(described_class).to receive(:substitute_starting_field_positions_arr)
      .and_return(
        %w[FWD MID MID MID MID DEF DEF DEF DEF DEF],
      )

    described_class.run!(fpl_team_list: fpl_team_list)

    expect(fpl_team_list.list_positions.starting).to contain_exactly(list_position_4)
    expect(fpl_team_list.list_positions.substitutes).to contain_exactly(
      list_position_1,
      list_position_2,
      list_position_3,
    )

    expect(fpl_team_list.total_score).to eq(player_4_total_points)
  end

  it 'player played no minutes in the first fixture but did play in the second will not get substituted' do
    round = FactoryBot.create(:round)
    team = FactoryBot.create(:team)
    fixture_1 = FactoryBot.create(:fixture, started: true, finished: true, round: round, home_team: team)
    fixture_2 = FactoryBot.create(:fixture, started: true, finished: true, round: round, away_team: team)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: round)

    player_1_total_points = 5

    fixture_histories_arr_1 = [
      {
        minutes: 0,
        total_points: 0,
        was_home: true,
        bps: 0,
        round: round,
        fixture: fixture_1,
      },
      {
        minutes: 80,
        total_points: player_1_total_points,
        was_home: false,
        bps: 15,
        round: round,
        fixture: fixture_2,
      }
    ]

    player_1 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    fixture_histories_arr_2 = [
      {
        minutes: 80,
        total_points: 4,
        was_home: false,
        bps: 14,
        round: round,
        fixture: fixture_1,
      }
    ]

    player_2 = FactoryBot.create(
      :player,
      :fwd,
      :player_fixture_histories,
      team: fixture_1.away_team,
      player_fixture_histories_arr: fixture_histories_arr_2,
    )

    fixture_1.update(
      stats: {
        bps: [
          { "value" => Faker::Number.number(2), "element" => Faker::Number.number(2) },
          { "value" => Faker::Number.number(2), "element" => Faker::Number.number(2) },
          { "value" => Faker::Number.number(2), "element" => Faker::Number.number(2) },
        ]
      }
    )

    fixture_2.update(
      stats: {
        bps: [
          { "value" => 15, "element" => player_1.id },
          { "value" => 14, "element" => player_2.id },
          { "value" => 13, "element" => player_2.id + 1 },
        ]
      }
    )

    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :fwd,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :s1,
      :fwd,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    expect_any_instance_of(described_class).not_to receive(:valid_substitution)

    described_class.run!(fpl_team_list: fpl_team_list)

    expect(fpl_team_list.list_positions.starting).to contain_exactly(list_position_1)
    expect(fpl_team_list.list_positions.substitutes).to contain_exactly(list_position_2)
    expect(fpl_team_list.total_score).to eq(player_1_total_points)
  end

  it 'starting goalkeeper played no minutes' do
    fixture = FactoryBot.create(:fixture, started: true, finished: true)
    fpl_team_list = FactoryBot.create(:fpl_team_list, round: fixture.round)

    fixture_histories_arr_1 = [
      {
        minutes: 0,
        total_points: 0,
        was_home: true,
        bps: 0,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_1 = FactoryBot.create(
      :player,
      :gkp,
      :player_fixture_histories,
      team: fixture.home_team,
      player_fixture_histories_arr: fixture_histories_arr_1,
    )

    player_2_total_points = 5

    fixture_histories_arr_2 = [
      {
        minutes: 80,
        total_points: player_2_total_points,
        was_home: false,
        bps: 1,
        round: fixture.round,
        fixture: fixture,
      }
    ]

    player_2 = FactoryBot.create(
      :player,
      :gkp,
      :player_fixture_histories,
      team: fixture.away_team,
      player_fixture_histories_arr: fixture_histories_arr_2,
    )

    bps_arr = [
      { "value" => 10, "element" => Faker::Number.number(5) },
      { "value" => 8, "element" => Faker::Number.number(5) },
      { "value" => 7, "element" => Faker::Number.number(5) },
    ]

    fixture.update(
      stats: {
        bps: bps_arr
      }
    )

    list_position_1 = FactoryBot.create(
      :list_position,
      :starting,
      :gkp,
      player: player_1,
      fpl_team_list: fpl_team_list,
    )

    list_position_2 = FactoryBot.create(
      :list_position,
      :sgkp,
      player: player_2,
      fpl_team_list: fpl_team_list,
    )

    described_class.run!(fpl_team_list: fpl_team_list)

    expect(list_position_1.reload.substitute_gkp?).to be_truthy
    expect(list_position_2.reload.starting?).to be_truthy
    expect(fpl_team_list.total_score).to eq(player_2_total_points)
  end
end
