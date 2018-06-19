require 'rails_helper'

RSpec.describe FplTeams::Hash do
  it 'no fpl team list' do
    league = FactoryBot.build_stubbed(:league, status: 'generate_draft_picks')
    user = FactoryBot.build_stubbed(:user)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, user: user, league: league)

    params = {
      user: user,
      fpl_team: fpl_team,
    }

    outcome = described_class.run(params)

    result = outcome.result

    expect(result[:fpl_team]).to eq(fpl_team)
    expect(result[:current_user]).to eq(user)
    expect(result[:league]).to eq(fpl_team.league)
    expect(result[:user_owns_fpl_team]).to be_truthy
    expect(result[:league_status]).to eq(league.status)
    expect(result[:fpl_team_lists]).to eq(fpl_team.fpl_team_lists)
  end

  it 'with an fpl team list' do
    league = FactoryBot.build_stubbed(:league, status: 'generate_draft_picks')
    user = FactoryBot.build_stubbed(:user)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, user: user, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team)

    expect(fpl_team_list).to receive(:save)
    fpl_team.fpl_team_lists << fpl_team_list

    show_list_positions = true
    show_waiver_picks = true


    params = {
      user: user,
      fpl_team: fpl_team,
      fpl_team_list: fpl_team_list,
      show_list_positions: show_list_positions,
      show_waiver_picks: show_waiver_picks,
    }

    expect_to_execute(
      FplTeamLists::Hash,
      with: {
        fpl_team_list: fpl_team_list,
        user: user,
        show_list_positions: show_list_positions,
        show_waiver_picks: show_waiver_picks,
        show_trade_groups: false,
        user_owns_fpl_team: fpl_team.user == user,
      },
      return: {},
    )

    outcome = described_class.run(params)
    result = outcome.result

    expect(result[:fpl_team]).to eq(fpl_team)
    expect(result[:fpl_team_list]).to eq(fpl_team_list)
    expect(result[:current_user]).to eq(user)
    expect(result[:league]).to eq(fpl_team.league)
    expect(result[:user_owns_fpl_team]).to be_truthy
    expect(result[:league_status]).to eq(league.status)
    expect(result[:fpl_team_lists]).to eq(fpl_team.fpl_team_lists)
  end
end
