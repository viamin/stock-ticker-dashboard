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
  test "should not save manipulation without category" do
    manipulation = Manipulation.new(newvalue: 10, message: "Test message", action: "add")
    assert_not manipulation.save, "Saved the manipulation without a category"
  end

  test "should not save manipulation with non-numeric newvalue" do
    manipulation = Manipulation.new(category: "test", newvalue: "abc", message: "Test message", action: "add")
    assert_not manipulation.save, "Saved the manipulation with a non-numeric newvalue"
  end

  test "should not save manipulation with message longer than 29 characters" do
    manipulation = Manipulation.new(category: "test", newvalue: 10, message: "a" * 30, action: "add")
    assert_not manipulation.save, "Saved the manipulation with a message longer than 29 characters"
  end

  test "should not save manipulation with non-ASCII message" do
    manipulation = Manipulation.new(category: "test", newvalue: 10, message: "テスト", action: "add")
    assert_not manipulation.save, "Saved the manipulation with a non-ASCII message"
  end

  test "should not save manipulation with invalid action" do
    manipulation = Manipulation.new(category: "test", newvalue: 10, message: "Test message", action: "invalid")
    assert_not manipulation.save, "Saved the manipulation with an invalid action"
  end

  test "should save valid manipulation" do
    manipulation = Manipulation.new(category: "test", newvalue: "10", message: "Test message", action: "add")
    assert manipulation.save, "Failed to save a valid manipulation"
  end

  test "to_json method should return correct JSON" do
    manipulation = Manipulation.new(category: "test", newvalue: "10", message: "Test message", action: "add")
    expected_json = {
      type: "market",
      category: "category",
      category_type: "test",
      action: "add",
      value_type: "literal",
      newvalue: "10"
    }.to_json
    assert_equal expected_json, manipulation.to_json
  end
end
