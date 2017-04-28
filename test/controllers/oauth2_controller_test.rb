require 'test_helper'

class Oauth2ControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get oauth2_index_url
    assert_response :success
  end

  test "should get auth" do
    get oauth2_auth_url
    assert_response :success
  end

  test "should get token" do
    get oauth2_token_url
    assert_response :success
  end

  test "should get callback" do
    get oauth2_callback_url
    assert_response :success
  end

end
