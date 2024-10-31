# == Schema Information
#
# Table name: manipulations
#
#  id            :integer          not null, primary key
#  manipulator   :string
#  message       :text
#  racc_username :string
#  ticker        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Manipulation < ApplicationRecord
  validates :message, presence: true, length: { maximum: 30 }


end
