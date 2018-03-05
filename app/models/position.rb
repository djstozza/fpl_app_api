# == Schema Information
#
# Table name: positions
#
#  id                  :integer          not null, primary key
#  singular_name       :string
#  singular_name_short :string
#  plural_name         :string
#  plural_name_short   :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Position < ApplicationRecord
  has_many :players
end
