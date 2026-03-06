require "test_helper"

class FindsControllerTest < ActionDispatch::IntegrationTest
  test "should get scan" do
    get finds_scan_url
    assert_response :success
  end

  test "should get new" do
    get finds_new_url
    assert_response :success
  end

  test "should get create" do
    get finds_create_url
    assert_response :success
  end

  test "should get index" do
    get finds_index_url
    assert_response :success
  end
end
