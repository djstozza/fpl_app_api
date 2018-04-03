# == Schema Information
#
# Table name: leagues
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  code            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  commissioner_id :integer
#  status          :integer          default("generate_draft_picks")
#

require 'rails_helper'

RSpec.describe League, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
