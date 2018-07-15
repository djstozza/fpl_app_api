require 'rails_helper'

RSpec.describe Rounds::Populate do
  it "creates a round" do
    response_hash = {
      "id" => 1,
      "name" => "Gameweek 1",
      "deadline_time" => "2018-08-10T18:00:00Z",
      "average_entry_score" => 0,
      "finished" => false,
      "data_checked" => false,
      "highest_scoring_entry" => nil,
      "deadline_time_epoch" => 1533924000,
      "deadline_time_game_offset" => 3600,
      "deadline_time_formatted" => "10 Aug 19:00",
      "highest_score" => nil,
      "is_previous" => false,
      "is_current" => false,
      "is_next" => true,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    described_class.run!

    round = Round.first

    expect(round.name).to eq(response_hash['name'])
    expect(round.deadline_time).to eq(DateTime.parse(response_hash['deadline_time']))
    expect(round.deadline_time_game_offset).to eq(response_hash['deadline_time_game_offset'])
    expect(round.finished).to be_falsy
    expect(round.data_checked).to be_falsy
    expect(round.is_current).to be_falsy
    expect(round.is_previous).to be_falsy
    expect(round.is_next).to be_truthy
  end

  it "updates an existing round" do
    round = FactoryBot.create(:round)
    response_hash = {
      "id" => round.id,
      "name" => "Gameweek 1",
      "deadline_time" => "2018-08-10T18:00:00Z",
      "average_entry_score" => 0,
      "finished" => false,
      "data_checked" => false,
      "highest_scoring_entry" => nil,
      "deadline_time_epoch" => 1533924000,
      "deadline_time_game_offset" => 3600,
      "deadline_time_formatted" => "10 Aug 19:00",
      "highest_score" => nil,
      "is_previous" => false,
      "is_current" => true,
      "is_next" => false,
    }

    expect(HTTParty).to receive(:get).and_return([response_hash]).at_least(1)

    described_class.run!

    expect(round.finished).to be_falsy
    expect(round.data_checked).to be_falsy
    expect(round.is_current).to be_truthy
    expect(round.is_previous).to be_falsy
    expect(round.is_next).to be_falsy
  end
end
