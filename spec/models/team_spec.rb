# == Schema Information
#
# Table name: teams
#
#  id                    :integer          not null, primary key
#  name                  :string
#  code                  :string
#  short_name            :string
#  strength              :integer
#  position              :integer
#  played                :integer
#  win                   :integer
#  loss                  :integer
#  draw                  :integer
#  points                :integer
#  form                  :integer
#  link_url              :integer
#  strength_overall_home :integer
#  strength_overall_away :integer
#  strength_attack_home  :integer
#  strength_attack_away  :integer
#  strength_defence_home :integer
#  strength_defence_away :integer
#  team_division         :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
