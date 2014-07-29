require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "should get dashboard" do
    get :dashboard
    assert_response :success
  end

  test "should get overview" do
    get :overview
    assert_response :success
  end

end
