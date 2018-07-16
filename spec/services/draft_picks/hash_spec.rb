require 'rails_helper'

RSpec.describe DraftPicks::Hash do
  context '#current_mini_draft_pick and #current_draft_pick_user' do
    it 'unprocessed draft pick' do
      round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)
      draft_pick = FactoryBot.create(:draft_pick, league: league)

      result = described_class.run!(league: league)
      expect(result[:current_draft_pick]).to eq(draft_pick)
      expect(result[:current_draft_pick_user]).to eq(draft_pick.user)
    end

    it 'player picked' do
      round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)
      FactoryBot.create(:draft_pick, :picked, league: league)

      result = described_class.run!(league: league)
      expect(result[:current_draft_pick]).to be_nil
      expect(result[:current_draft_pick_user]).to be_nil
    end

    it 'mini_draft pick number picked' do
      round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)
      FactoryBot.create(:draft_pick, :mini_draft, league: league)

      result = described_class.run!(league: league)
      expect(result[:current_draft_pick]).to be_nil
      expect(result[:current_draft_pick_user]).to be_nil
    end
  end

  context '#unpicked_players' do
    it 'before the summer mini draft deadline' do
      first_round_deadline_time = Time.new(2018, 8, 10)
      round = FactoryBot.build_stubbed(:round, deadline_time: first_round_deadline_time)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)

      FactoryBot.create(:player, created_at: first_round_deadline_time)

      Timecop.freeze Round.summer_mini_draft_deadline

      player = FactoryBot.create(:player)

      result = described_class.run!(league: league)
      expect(result[:unpicked_players]).to eq(PlayerDecorator.new(Player.where.not(id: player.id)).players_hash)

      Timecop.return
    end

    it 'before the winter mini draft deadline' do
      first_round_deadline_time = Time.new(2018, 8, 10)
      round = FactoryBot.build_stubbed(:round, deadline_time: first_round_deadline_time)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)

      FactoryBot.create(:player, created_at: first_round_deadline_time)
      FactoryBot.create(:player, created_at: Round.summer_mini_draft_deadline - 1)

      Timecop.freeze Round.summer_mini_draft_deadline

      player = FactoryBot.create(:player)

      result = described_class.run!(league: league)
      expect(result[:unpicked_players]).to eq(PlayerDecorator.new(Player.where.not(id: player.id)).players_hash)

      Timecop.return
    end

    it 'before the winter mini draft deadline' do
      first_round_deadline_time = Time.new(2018, 8, 10)
      round = FactoryBot.build_stubbed(:round, deadline_time: first_round_deadline_time)
      expect(Round).to receive(:first).and_return(round).at_least(1)

      league = FactoryBot.create(:league)

      FactoryBot.create(:player, created_at: first_round_deadline_time)
      FactoryBot.create(:player, created_at: Round.winter_mini_draft_deadline - 1)

      Timecop.freeze Round.winter_mini_draft_deadline

      player = FactoryBot.create(:player)

      result = described_class.run!(league: league)
      expect(result[:unpicked_players]).to eq(PlayerDecorator.new(Player.where.not(id: player.id)).players_hash)

      Timecop.return
    end
  end

  it '#all_players_picked' do
    round = FactoryBot.build_stubbed(:round)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    league = FactoryBot.create(:league)
    fpl_team = FactoryBot.create(:fpl_team, league: league)

    FplTeam::QUOTAS[:players].times { FactoryBot.create(:draft_pick, :picked, league: league, fpl_team: fpl_team) }

    FactoryBot.create(:draft_pick, league: league, fpl_team: fpl_team)

    result = described_class.run!(league: league)

    expect(result[:all_players_picked]).to be_truthy
  end

  it '#mini_draft_picked' do
    round = FactoryBot.build_stubbed(:round)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    league = FactoryBot.create(:league)
    fpl_team = FactoryBot.create(:fpl_team, league: league)

    FactoryBot.create(:draft_pick, :mini_draft, league: league, fpl_team: fpl_team)
    FactoryBot.create(:draft_pick, league: league, fpl_team: fpl_team)

    result = described_class.run!(league: league)

    expect(result[:mini_draft_picked]).to be_truthy
  end

  it '#all_draft_picks' do
    round = FactoryBot.build_stubbed(:round)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    league = FactoryBot.create(:league)

    draft_pick_1 = FactoryBot.create(:draft_pick, :picked, league: league)
    draft_pick_2 = FactoryBot.create(:draft_pick, :mini_draft, league: league)

    result = described_class.run!(league: league)

    expect(result[:draft_picks]).to contain_exactly(
      {
        "id" => draft_pick_1.id,
        "pick_number" => draft_pick_1.pick_number,
        "fpl_team_id" => draft_pick_1.fpl_team_id,
        "fpl_team_name" => draft_pick_1.fpl_team.name,
        "player_id" => draft_pick_1.player_id,
        "position_id" => draft_pick_1.player.position_id,
        "singular_name_short" => draft_pick_1.player.position.singular_name_short,
        "team_id" => draft_pick_1.player.team_id,
        "short_name" => draft_pick_1.player.team.short_name,
        "team_name" => draft_pick_1.player.team.name,
        "first_name" => draft_pick_1.player.first_name,
        "last_name" => draft_pick_1.player.last_name,
        "mini_draft" => false
      },
      {
        "id" => draft_pick_2.id,
        "pick_number" => draft_pick_2.pick_number,
        "fpl_team_id" => draft_pick_2.fpl_team_id,
        "fpl_team_name" => draft_pick_2.fpl_team.name,
        "player_id" => nil,
        "position_id" => nil,
        "singular_name_short" => nil,
        "team_id" => nil,
        "short_name" => nil,
        "team_name" => nil,
        "first_name" => nil,
        "last_name" => nil,
        "mini_draft" => true
      },
    )
  end
end
