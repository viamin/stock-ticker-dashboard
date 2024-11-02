# == Schema Information
#
# Table name: manipulations
#
#  id            :integer          not null, primary key
#  action        :string
#  category      :string
#  manipulator   :string
#  message       :text
#  newvalue      :string
#  racc_username :string
#  value_type    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class ManipulationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
