require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get homepage" do
    get :homepage
    assert_response :success
  end

end
