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
require "test_helper"

class ManipulationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
