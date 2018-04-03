# == Schema Information
#
# Table name: fpl_team_lists
#
#  id          :integer          not null, primary key
#  fpl_team_id :integer
#  round_id    :integer
#  total_score :integer
#  rank        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class FplTeamList < ApplicationRecord
end
