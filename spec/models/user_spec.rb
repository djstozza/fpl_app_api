require 'rails_helper'

RSpec.describe User, type: :model do
  it 'requires a unique username and email' do
    user = FactoryBot.create(:user)
    expect(FactoryBot.build(:user, username: user.username.upcase)).not_to be_valid
    expect(FactoryBot.build(:user, email: user.email.upcase)).not_to be_valid
  end

  it 'requires a valid email address' do
    expect(FactoryBot.build(:user, email: 'invalid@email;com')).not_to be_valid
  end
end
