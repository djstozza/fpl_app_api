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
             :clean_sheets,
             :points,
             :form,
             :current_form,
             :goals_for,
             :goals_against,
             :goal_difference,
             :strength_overall_home,
             :strength_overall_away,
             :strength_attack_home,
             :strength_attack_away,
             :strength_defence_home,
             :strength_overall_away

  has_many :home_fixtures, class: Fixture, foreign_key: :team_h_id, serializer: :fixture
  has_many :away_fixtures, class: Fixture, foreign_key: :team_a_id, serializer: :fixture
  has_many :players, class: Player, foreign_key: :team_id, serializer: :players
end
