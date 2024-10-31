require "test_helper"

class ManipulationControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manipulation_index_url
    assert_response :success
  end

  test "should get new" do
    get manipulation_new_url
    assert_response :success
  end

  test "should get create" do
    get manipulation_create_url
    assert_response :success
  end

  test "should get show" do
    get manipulation_show_url
    assert_response :success
  end
end
