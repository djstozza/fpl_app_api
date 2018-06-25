require 'rails_helper'

RSpec.describe MiniDraftPicks::Hash do
  it '#league' do
    round = FactoryBot.build_stubbed(:round)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    user = FactoryBot.build_stubbed(:user)
    outcome = described_class.run(league: league, user: user)

    expect(outcome.result[:league]).to eq(league)
  end

  it '#current_user' do
    round = FactoryBot.build_stubbed(:round)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    user = FactoryBot.build_stubbed(:user)
    outcome = described_class.run(league: league, user: user)

    expect(outcome.result[:current_user]).to eq(user)
  end

  context '#season' do
    it 'is winter if current time is > the deadline time of the first round' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.ago)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.build_stubbed(:league)
      user = FactoryBot.build_stubbed(:user)
      outcome = described_class.run(league: league, user: user)
      expect(outcome.result[:season]).to eq('winter')
    end

    it 'is summer if the current time is < the deadline time of the first round' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.from_now)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.build_stubbed(:league)
      user = FactoryBot.build_stubbed(:user)
      outcome = described_class.run(league: league, user: user)
      expect(outcome.result[:season]).to eq('summer')
    end
  end

  context '#next_fpl_team, #current_mini_draft_pick and #current_mini_draft_pick_user' do
    it 'is dependent on mini_draft_pick_number if summer' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.from_now)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)
      user = FactoryBot.create(:user)
      fpl_team_1 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 1)
      fpl_team_2 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 2)

      outcome = described_class.run(league: league, user: user)
      result = outcome.result

      expect(result[:season]).to eq('summer')
      expect(result[:fpl_teams]).to include(fpl_team_1, fpl_team_2)
      expect(result[:next_fpl_team]).to eq(fpl_team_1)

      current_mini_draft_pick = result[:current_mini_draft_pick]

      expect(current_mini_draft_pick.id).to be_nil
      expect(current_mini_draft_pick.pick_number).to eq(1)
      expect(current_mini_draft_pick.fpl_team).to eq(fpl_team_1)
      expect(current_mini_draft_pick.league).to eq(league)
      expect(current_mini_draft_pick.season).to eq('summer')

      expect(result[:current_mini_draft_pick_user]).to eq(fpl_team_1.user)
    end

    it 'is dependent on rank if winter' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.ago)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)
      user = FactoryBot.create(:user)
      fpl_team_1 = FactoryBot.create(:fpl_team, league: league, rank: 1)
      fpl_team_2 = FactoryBot.create(:fpl_team, league: league, rank: 2)

      outcome = described_class.run(league: league, user: user)
      result = outcome.result

      expect(result[:season]).to eq('winter')
      expect(result[:fpl_teams]).to include(fpl_team_1, fpl_team_2)
      expect(result[:next_fpl_team]).to eq(fpl_team_2)

      current_mini_draft_pick = result[:current_mini_draft_pick]

      expect(current_mini_draft_pick.id).to be_nil
      expect(current_mini_draft_pick.pick_number).to eq(1)
      expect(current_mini_draft_pick.fpl_team).to eq(fpl_team_2)
      expect(current_mini_draft_pick.league).to eq(league)
      expect(current_mini_draft_pick.season).to eq('winter')

      expect(result[:current_mini_draft_pick_user]).to eq(fpl_team_2.user)
    end
  end

  context '#consecutive_passes' do
    it 'shows whether the next_fpl_team has had consecutive passes' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.from_now)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      current_round = FactoryBot.create(:round, mini_draft: true, is_current: true)

      league = FactoryBot.create(:league)
      user = FactoryBot.create(:user)
      fpl_team_1 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 1)
      fpl_team_2 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 2)

      FactoryBot.create(:mini_draft_pick, :summer, :passed, fpl_team: fpl_team_1, round: current_round, league: league)
      FactoryBot.create(:mini_draft_pick, :summer, :passed, fpl_team: fpl_team_2, round: current_round, league: league)
      FactoryBot.create(:mini_draft_pick, :summer, :passed, fpl_team: fpl_team_1, round: current_round, league: league)

      outcome = described_class.run(league: league, user: user)
      result = outcome.result

      expect(result[:next_fpl_team]).to eq(fpl_team_1)
      expect(result[:consecutive_passes]).to be_truthy
    end
  end

  context '#all_fpl_teams_passed?' do
    it 'has no next_fpl_team if all fpl_teams have consecutive passes' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.from_now)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      current_round = FactoryBot.create(:round, mini_draft: true, is_current: true)

      league = FactoryBot.create(:league)
      user = FactoryBot.create(:user)

      fpl_team = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 1)

      FactoryBot.create(
        :mini_draft_pick,
        :summer,
        :passed,
        fpl_team: fpl_team,
        round: current_round,
        league: league,
        pick_number: 1,
      )

      FactoryBot.create(
        :mini_draft_pick,
        :summer,
        :passed,
        fpl_team: fpl_team,
        round: current_round,
        league: league,
        pick_number: 2,
      )

      outcome = described_class.run(league: league, user: user)
      result = outcome.result

      expect(result[:next_fpl_team]).to be_nil

      current_mini_draft_pick = result[:current_mini_draft_pick]

      expect(current_mini_draft_pick.id).to be_nil
      expect(current_mini_draft_pick.fpl_team).to be_nil
      expect(current_mini_draft_pick.pick_number).to eq(MiniDraftPick.count + 1)
    end
  end

  context '#mini_draft_picks' do
    it 'shows all non passed mini_draft_picks' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.year.from_now)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      current_round = FactoryBot.create(:round, mini_draft: true, is_current: true)

      league = FactoryBot.create(:league)
      user = FactoryBot.create(:user)

      fpl_team_1 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 1)
      fpl_team_2 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 2)

      mini_draft_pick_1 =
        FactoryBot.create(
          :mini_draft_pick,
          :summer,
          :passed,
          fpl_team: fpl_team_1,
          round: current_round,
          league: league,
          pick_number: 1,
        )

      mini_draft_pick_2 =
        FactoryBot.create(
          :mini_draft_pick,
          :summer,
          :picked,
          fpl_team: fpl_team_2,
          round: current_round,
          league: league,
          pick_number: 2,
        )

      outcome = described_class.run(league: league, user: user)
      result = outcome.result

      expect(result[:mini_draft_picks].pluck(:id)).to include(mini_draft_pick_2.id)
      expect(result[:mini_draft_picks].pluck(:id)).not_to include(mini_draft_pick_1.id)

      in_player = mini_draft_pick_2.in_player
      out_player = mini_draft_pick_2.out_player


      expect(result[:mini_draft_picks]).to include(
        {
          "id" => mini_draft_pick_2.id,
          "pick_number" => mini_draft_pick_2.pick_number,
          "singular_name_short" => out_player.position.singular_name_short,
          "in_player_id" => in_player.id,
          "in_first_name" => in_player.first_name,
          "in_last_name" => in_player.last_name,
          "fpl_team_name" => fpl_team_2.name,
          "in_team_short_name" => in_player.team.short_name,
          "out_player_id"=> out_player.id,
          "out_first_name"=> out_player.first_name,
          "out_last_name" => out_player.last_name,
          "out_team_short_name" => out_player.team.short_name,
        }
      )
    end
  end
end
