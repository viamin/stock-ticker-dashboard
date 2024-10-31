require "test_helper"

class ManipulationControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manipulation_index_url
    assert_response :success
  end

  test "should get new" do
    get new_manipulation_url
    assert_response :success
  end

  test "should get create" do
    post manipulation_index_url
    assert_response :success
  end

  # test "should get show" do
  #   get manipulation_url
  #   assert_response :success
  # end
end
