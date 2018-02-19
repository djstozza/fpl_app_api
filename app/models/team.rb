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
#  wins                  :integer
#  losses                :integer
#  draws                 :integer
#  clean_sheets          :integer
#  goals_for             :integer
#  goals_against         :integer
#  goal_difference       :integer
#  points                :integer
#  form                  :jsonb
#  current_form          :string
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

class Team < ApplicationRecord
  has_many :players
  has_many :home_fixtures, class_name: 'Fixture', foreign_key: :team_h_id
  has_many :away_fixtures, class_name: 'Fixture', foreign_key: :team_a_id

  validates :code, :name, :short_name, presence: true, uniqueness: true
end
