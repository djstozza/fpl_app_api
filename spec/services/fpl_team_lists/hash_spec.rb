require 'rails_helper'

describe FplTeamLists::Hash do
  context '#status' do
    it '#mini_draft' do
      round = FactoryBot.build_stubbed(:round, mini_draft: true, deadline_time: 2.days.from_now)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('mini_draft')
    end

    it '#waiver' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      expect(Round).to receive(:first).and_return(double(Round, id: 1)).at_least(1)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('waiver')
    end

    it '#trade' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.day.from_now)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('trade')
    end

    it 'has status of trade if the deadline time has not been passed and first round' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      expect(Round).to receive(:first).and_return(double(Round, id: round.id)).at_least(1)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('trade')
    end

    it '#pre_game' do
      round = FactoryBot.build_stubbed(:round, deadline_time: Time.now, deadline_time_game_offset: 3600)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('pre_game')
    end

    it '#finished' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.day.ago, data_checked: true)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('finished')
    end

    it '#started' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.day.ago)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:status]).to eq('started')
    end
  end

  context '#editable' do
    it 'is editable if the status is mini_draft and the user owns the fpl_team' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('mini_draft')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:editable]).to be_truthy
    end

    it 'is editable if the status is waiver and the user owns the fpl_team' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('waiver')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)

      expect(result[:editable]).to be_truthy
    end

    it 'is editable if the status is trade and the user owns the fpl_team' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('trade')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to be_truthy
    end

    it 'is not editable if the status is started and the user owns the fpl_team' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('started')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to eq('false')
    end

    it 'is not editable if the status is finished and the user owns the fpl_team' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('finished')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to eq('false')
    end

    it 'is not editable if the status is pre_game and the user owns the fpl_team' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('pre_game')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to eq('false')
    end

    it 'is not editable if the user does not own the fpl_team' do
      user = FactoryBot.build_stubbed(:user)
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('waiver')

      result = described_class.run!(user: user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to eq('false')

      allow_any_instance_of(described_class).to receive(:status).and_return('mini_draft')

      result = described_class.run!(user: user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to eq('false')

      allow_any_instance_of(described_class).to receive(:status).and_return('trade')

      result = described_class.run!(user: user, fpl_team_list: fpl_team_list)
      expect(result[:editable]).to eq('false')
    end
  end

  context '#show_score' do
    it 'is true if status is started or finished' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('started')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:show_score]).to be_truthy

      allow_any_instance_of(described_class).to receive(:status).and_return('finished')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:show_score]).to be_truthy
    end

    it 'is false if status is not started or finished' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)
      fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

      allow_any_instance_of(described_class).to receive(:status).and_return('waiver')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:show_score]).to eq('false')

      allow_any_instance_of(described_class).to receive(:status).and_return('trade')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:show_score]).to eq('false')

      allow_any_instance_of(described_class).to receive(:status).and_return('mini_draft')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:show_score]).to eq('false')

      allow_any_instance_of(described_class).to receive(:status).and_return('pre_game')

      result = described_class.run!(user: fpl_team.user, fpl_team_list: fpl_team_list)
      expect(result[:show_score]).to eq('false')
    end
  end

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
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      result = described_class.run!(params)

      hash = list_position_hash(
        player_fixture_histories_arr.first.merge(
          fpl_team_list: fpl_team_list,
          list_position: list_position,
          position: position,
          player: player,
          fixture: fixture,
        )
      )

      expect(result[:list_positions]).to contain_exactly(hash)
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to contain_exactly(hash)
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
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      result = described_class.run!(params)

      hash = list_position_hash(
        player_fixture_histories_arr.first.merge(
          fpl_team_list: fpl_team_list,
          list_position: list_position,
          position: position,
          player: player,
          fixture: fixture,
        )
      )

      expect(result[:list_positions]).to contain_exactly(hash)
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to contain_exactly(hash)
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
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      result = described_class.run!(params)

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
        "round_id" => round.id,
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

      expect(result[:list_positions]).to contain_exactly(hash)
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to contain_exactly(hash)
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
        fpl_team_list: fpl_team_list,
        show_list_positions: true,
      }

      result = described_class.run!(params)

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

      expect(result[:list_positions]).to contain_exactly(hash_1, hash_2)

      hash_1['fixture_points'] += hash_2['fixture_points']
      hash_1['fixture'] += ", #{hash_2['fixture']}"
      expect(result.dig(:grouped_list_positions, role, position.singular_name_short)).to contain_exactly(hash_1)
    end

    context '#show_waiver_picks' do
      it 'shows waiver picks if the user owns the fpl team' do
        user = FactoryBot.create(:user)
        fpl_team = FactoryBot.create(:fpl_team, user: user)
        fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)

        waiver_pick = FactoryBot.create(
          :waiver_pick,
          fpl_team_list: fpl_team_list,
          league: fpl_team.league,
          round: fpl_team_list.round,
        )

        params = {
          user: user,
          fpl_team_list: fpl_team_list,
          show_waiver_picks: true,
        }

        result = described_class.run!(params)

        out_player = waiver_pick.out_player
        in_player = waiver_pick.in_player

        expect(result[:waiver_picks]).to contain_exactly({
          "id" => waiver_pick.id,
          "pick_number" => waiver_pick.pick_number,
          "status" => waiver_pick.status,
          "singular_name_short" => out_player.position.singular_name_short,
          "in_player_id" => waiver_pick.in_player_id,
          "in_first_name" => in_player.first_name,
          "in_last_name" => in_player.last_name,
          "in_team_short_name" => in_player.team.short_name,
          "out_player_id" => waiver_pick.out_player_id,
          "out_first_name" => out_player.first_name,
          "out_last_name" => out_player.last_name,
          "out_team_short_name" => out_player.team.short_name,
        })
      end

      it 'does not show waiver picks if the user does not own the fpl team' do
        user = FactoryBot.create(:user)
        fpl_team = FactoryBot.create(:fpl_team)
        fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)

        FactoryBot.create(
          :waiver_pick,
          fpl_team_list: fpl_team_list,
          league: fpl_team.league,
          round: fpl_team_list.round,
        )

        params = {
          user: user,
          fpl_team_list: fpl_team_list,
          show_waiver_picks: true,
        }

        result = described_class.run!(params)
        expect(result[:waiver_picks]).to be_nil
      end
    end

    context '#show_trade_groups' do
      it 'shows all inter team trades' do
        user = FactoryBot.create(:user)
        round = FactoryBot.create(:round)
        league = FactoryBot.create(:league)

        fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
        fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

        fpl_team_2 = FactoryBot.create(:fpl_team, league: league)
        fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round)

        player_1 = FactoryBot.create(:player)
        player_2 = FactoryBot.create(:player)
        player_3 = FactoryBot.create(:player)
        player_4 = FactoryBot.create(:player)

        fpl_team.players << player_1
        fpl_team.players << player_2

        fpl_team_2.players << player_3
        fpl_team_2.players << player_4

        out_trade_group = FactoryBot.create(
          :inter_team_trade_group,
          out_fpl_team_list: fpl_team_list,
          in_fpl_team_list: fpl_team_list_2,
          league: league,
          round: round,
          status: 'pending'
        )

        inter_team_trade_1 = FactoryBot.create(
          :inter_team_trade,
          inter_team_trade_group: out_trade_group,
          out_player: player_1,
          in_player: player_3,
        )

        in_trade_group = FactoryBot.create(
          :inter_team_trade_group,
          out_fpl_team_list: fpl_team_list_2,
          in_fpl_team_list: fpl_team_list,
          league: league,
          round: round,
          status: 'submitted',
        )

        inter_team_trade_2 = FactoryBot.create(
          :inter_team_trade,
          inter_team_trade_group: in_trade_group,
          out_player: player_4,
          in_player: player_2,
        )

        params = {
          user: user,
          fpl_team_list: fpl_team_list,
          show_trade_groups: true,
        }

        result = described_class.run!(params)

        expect(result.dig(:out_trade_groups, 'pending')).to contain_exactly(
          trade_group_hash(
            trade_group: out_trade_group,
            inter_team_trade: inter_team_trade_1,
            out_player: player_1,
            in_player: player_3,
            fpl_team: fpl_team_2,
            type: "in",
          )
        )

        expect(result.dig(:in_trade_groups, 'submitted')).to contain_exactly(
          trade_group_hash(
            trade_group: in_trade_group,
            inter_team_trade: inter_team_trade_2,
            out_player: player_4,
            in_player: player_2,
            fpl_team: fpl_team_2,
            type: "out",
          )
        )
      end

      it 'does not show in trade groups that have a pending status' do
        user = FactoryBot.create(:user)
        round = FactoryBot.create(:round)
        league = FactoryBot.create(:league)

        fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
        fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

        fpl_team_2 = FactoryBot.create(:fpl_team, league: league)
        fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round)

        player_1 = FactoryBot.create(:player)
        player_2 = FactoryBot.create(:player)

        fpl_team.players << player_1
        fpl_team_2.players << player_2

        in_trade_group = FactoryBot.create(
          :inter_team_trade_group,
          out_fpl_team_list: fpl_team_list_2,
          in_fpl_team_list: fpl_team_list,
          league: league,
          round: round,
          status: 'pending',
        )

        FactoryBot.create(
          :inter_team_trade,
          inter_team_trade_group: in_trade_group,
          out_player: player_2,
          in_player: player_1,
        )

        params = {
          user: user,
          fpl_team_list: fpl_team_list,
          show_trade_groups: true,
        }

        result = described_class.run!(params)
        expect(result[:in_trade_groups]).to be_empty
      end

      it 'is invalid if the user does not own the fpl team' do
        user = FactoryBot.create(:user)

        fpl_team = FactoryBot.create(:fpl_team)
        fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)

        params = {
          user: user,
          fpl_team_list: fpl_team_list,
          show_trade_groups: true,
        }

        outcome = described_class.run(params)
        expect(outcome).not_to be_valid
      end
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

  def trade_group_hash(trade_group:, inter_team_trade:, out_player:, in_player:, fpl_team:, type:)
    {
      id: trade_group.id,
      trades: [
        {
          "id" => inter_team_trade.id,
          "in_player_id" => in_player.id,
          "in_player_last_name" => in_player.last_name,
          "in_team_short_name" => in_player.team.short_name,
          "out_player_id" => out_player.id,
          "out_player_last_name" => out_player.last_name,
          "out_team_short_name" => out_player.team.short_name,
          "singular_name_short" => out_player.position.singular_name_short,
        }
      ],
      status: trade_group.status,
      "#{type}_fpl_team": fpl_team,
    }
  end

  def role(list_position:)
    list_position.role.gsub(/tarting|ubstitute_/, '').upcase
  end
end
