# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  provider               :string           default("email"), not null
#  uid                    :string           not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  allow_password_change  :boolean          default(FALSE)
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  username               :string           not null
#  image                  :string
#  email                  :string           not null
#  tokens                 :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

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
