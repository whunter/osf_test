require 'test_helper'

class ApiRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get api_requests_list_url
    assert_response :success
  end

  test "should get detail" do
    get api_requests_detail_url
    assert_response :success
  end

end
