require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get link_coinbase_account" do
    get :link_coinbase_account
    assert_response :success
  end

  test "should get unlink_coinbase_account" do
    get :unlink_coinbase_account
    assert_response :success
  end

end
