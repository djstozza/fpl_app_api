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

class TeamSerializer
  include FastJsonapi::ObjectSerializer
  set_type :team
  attributes :name,
             :code,
             :short_name,
             :strength,
             :position,
             :played,
             :wins,
             :losses,
             :draws,
             :points,
             :form,
             :current_form,
             :strength_overall_home,
             :strength_overall_away,
             :strength_attack_home,
             :strength_attack_away,
             :strength_defence_home,
             :strength_overall_away

  has_many :home_fixtures, class: Fixture, foreign_key: :team_h_id, serializer: :fixture
  has_many :away_fixtures, class: Fixture, foreign_key: :team_a_id, serializer: :fixture
end
