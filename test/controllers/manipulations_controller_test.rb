require "test_helper"

class ManipulationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    skip "not implemented"
    get manipulations_url
    assert_response :success
  end

  test "should get new" do
    get new_manipulation_url
    assert_response :success
  end

  test "should create" do
    skip "TODO: need params"
    post manipulations_url
    assert_response :success
  end

  # test "should get show" do
  #   get manipulation_url
  #   assert_response :success
  # end
end
