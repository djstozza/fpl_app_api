require 'rails_helper'

describe FplTeamLists::Hash do
  context '#show_list_positions' do
    it 'home fixture, fixture started' do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round)
      fixture = FactoryBot.create(:fixture, started: true, finished: false, round: round)

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      position = Position.find_by(singular_name_short: 'FWD')

      bps = 15

      player_fixture_histories_arr = [
        {
          minutes: 80,
          total_points: 5,
          was_home: true,
          bps: bps,
          round: round,
          fixture: fixture,
        }
      ]

      player = FactoryBot.create(
        :player,
        :player_fixture_histories,
        :"#{position.singular_name_short.downcase}",
        team: fixture.home_team,
        player_fixture_histories_arr: player_fixture_histories_arr,
      )

      list_position = FactoryBot.create(
        :list_position,
        :starting,
        player: player,
        position: position,
        fpl_team_list: fpl_team_list
      )

      role = role(list_position: list_position)

      fixture.update(stats: {
        bps: [
          { "value" => bps, "element" => player.id },
          { "value" => bps - 1, "element" => player.id + 1 },
          { "value" => bps - 2, "element" => player.id + 2 },
        ]
      })

      bonus = 3
      player_fixture_histories_arr.first[:total_points] += bonus

      params = {
        user: user,
        fpl_team: fpl_team,
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      outcome = described_class.run(params)
      result = outcome.result

      hash = list_position_hash(
        player_fixture_histories_arr.first.merge(
          fpl_team_list: fpl_team_list,
          list_position: list_position,
          position: position,
          player: player,
          fixture: fixture,
        )
      )

      expect(result[:list_positions]).to include(hash)
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to include(hash)
    end

    it 'away fixture, fixture finished' do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round)
      fixture = FactoryBot.create(:fixture, started: true, finished: true, round: round)

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      position = Position.find_by(singular_name_short: 'MID')

      bps = 15

      player_fixture_histories_arr = [
        {
          minutes: 80,
          total_points: 5,
          was_home: false,
          bps: bps,
          round: round,
          fixture: fixture,
        }
      ]

      player = FactoryBot.create(
        :player,
        :player_fixture_histories,
        :"#{position.singular_name_short.downcase}",
        team: fixture.away_team,
        player_fixture_histories_arr: player_fixture_histories_arr,
      )

      list_position = FactoryBot.create(
        :list_position,
        :starting,
        player: player,
        position: position,
        fpl_team_list: fpl_team_list
      )

      role = role(list_position: list_position)

      fixture.update(stats: {
        bps: [
          { "value" => bps, "element" => player.id },
          { "value" => bps - 1, "element" => player.id + 1 },
          { "value" => bps - 2, "element" => player.id + 2 },
        ]
      })

      params = {
        user: user,
        fpl_team: fpl_team,
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      outcome = described_class.run(params)
      result = outcome.result

      hash = list_position_hash(
        player_fixture_histories_arr.first.merge(
          fpl_team_list: fpl_team_list,
          list_position: list_position,
          position: position,
          player: player,
          fixture: fixture,
        )
      )

      expect(result[:list_positions]).to include(hash)
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to include(hash)
    end

    it 'bye' do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round)

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, :def, :s1, fpl_team_list: fpl_team_list)

      player = list_position.player
      position = list_position.position
      team = player.team

      role = role(list_position: list_position)

      params = {
        user: user,
        fpl_team: fpl_team,
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      outcome = described_class.run(params)
      result = outcome.result

      hash = {
        "id" => list_position.id,
        "player_id" => player.id,
        "role" => role,
        "first_name" => player.first_name,
        "last_name" => player.last_name,
        "position_id" => position.id,
        "singular_name_short" => position.singular_name_short,
        "team_id" => team.id,
        "team_short_name" => team.short_name,
        "status" => "fa fa-check-circle",
        "total_points" => player.total_points,
        "fpl_team_list_id" => fpl_team_list.id,
        "team_h_id" => nil,
        "team_a_id" => nil,
        "event_points" => nil,
        "started" => nil,
        "finished" => nil,
        "finished_provisional" => nil,
        "news" => nil,
        "fixture_id" => nil,
        "round_id" => 3,
        "opponent_short_name" => nil,
        "opponent_id" => nil,
        "team_h_difficulty" => nil,
        "team_a_difficulty" => nil,
        "minutes" => nil,
        "fixture_points" => nil,
        "home" => nil,
        "bps" => nil,
        "i" => 0,
        "fixture" => "BYE",
      }

      expect(result[:list_positions]).to include(hash)
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to include(hash)
    end

    it 'two player fixture histories in one round' do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round)
      team = FactoryBot.create(:team)
      fixture_1 = FactoryBot.create(:fixture, started: true, finished: false, round: round, home_team: team)
      fixture_2 = FactoryBot.create(:fixture, started: true, finished: true, round: round, away_team: team)

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      position = Position.find_by(singular_name_short: 'GKP')

      bps = 15

      player_fixture_histories_arr = [
        {
          minutes: 80,
          total_points: 5,
          was_home: true,
          bps: bps,
          round: round,
          fixture: fixture_1,
        },
        {
          minutes: 80,
          total_points: 5,
          was_home: false,
          bps: bps,
          round: round,
          fixture: fixture_2,
        }
      ]

      player = FactoryBot.create(
        :player,
        :player_fixture_histories,
        :"#{position.singular_name_short.downcase}",
        team: team,
        player_fixture_histories_arr: player_fixture_histories_arr,
      )

      list_position = FactoryBot.create(
        :list_position,
        :starting,
        player: player,
        position: position,
        fpl_team_list: fpl_team_list
      )

      bonus = 2
      player_fixture_histories_arr.first[:total_points] += bonus

      role = role(list_position: list_position)

      fixture_1.update(stats: {
        bps: [
          { "value" => bps + 1, "element" => player.id + 1 },
          { "value" => bps, "element" => player.id },
          { "value" => bps - 2, "element" => player.id + 2 },
        ]
      })

      fixture_2.update(stats: {
        bps: [
          { "value" => bps + 1, "element" => player.id + 1 },
          { "value" => bps, "element" => player.id },
          { "value" => bps - 2, "element" => player.id + 2 },
        ]
      })

      params = {
        user: user,
        fpl_team: fpl_team,
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      outcome = described_class.run(params)
      result = outcome.result

      hash_1 = list_position_hash(
        player_fixture_histories_arr.first.merge(
          fpl_team_list: fpl_team_list,
          list_position: list_position,
          position: position,
          player: player,
          fixture: fixture_1,
        )
      )

      hash_2 = list_position_hash(
        player_fixture_histories_arr.second.merge(
          fpl_team_list: fpl_team_list,
          list_position: list_position,
          position: position,
          player: player,
          fixture: fixture_2,
          i: 1,
        )
      )

      expect(result[:list_positions]).to include(hash_1, hash_2)

      hash_1['fixture_points'] += hash_2['fixture_points']
      hash_1['fixture'] += ", #{hash_2['fixture']}"
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to include(hash_1)
    end
  end

  private

  def list_position_hash(
    fpl_team_list:,
    list_position:,
    position:,
    round:,
    player:,
    fixture:,
    minutes:,
    total_points:,
    was_home:,
    bps:,
    i: 0
  )
    team = player.team
    opponent = was_home ? fixture.away_team : fixture.home_team
    leg = was_home ? 'H' : 'A'
    role = role(list_position: list_position)
    advantage =
      if was_home
        fixture.team_h_difficulty - fixture.team_a_difficulty
      else
        fixture.team_a_difficulty - fixture.team_h_difficulty
      end

    {
      "id" => list_position.id,
      "player_id" => player.id,
      "role" => role,
      "first_name" => player.first_name,
      "last_name" => player.last_name,
      "position_id" => position.id,
      "singular_name_short" => position.singular_name_short,
      "team_id" => team.id,
      "team_short_name" => team.short_name,
      "status" => "fa fa-check-circle",
      "total_points" => player.total_points,
      "fpl_team_list_id" => fpl_team_list.id,
      "team_h_id" => fixture.team_h_id,
      "team_a_id" => fixture.team_a_id,
      "event_points" => player.event_points,
      "started" => fixture.started,
      "finished" => fixture.finished,
      "finished_provisional" => fixture.finished_provisional,
      "news" => player.news,
      "fixture_id" => fixture.id,
      "round_id" => fixture.round_id,
      "opponent_short_name" => opponent.short_name,
      "opponent_id" => opponent.id,
      "team_h_difficulty" => fixture.team_h_difficulty,
      "team_a_difficulty" => fixture.team_a_difficulty,
      "minutes" => minutes,
      "fixture_points" => total_points,
      "home" => was_home,
      "bps" => fixture.stats["bps"],
      "i" => i,
      "leg" => leg,
      "advantage" => advantage,
      "fixture" => "#{opponent.short_name} (#{leg})",
    }
  end

  def role(list_position:)
    list_position.role.gsub(/tarting|ubstitute_/, '').upcase
  end
end
