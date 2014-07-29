require 'test_helper'

class TransactionControllerTest < ActionController::TestCase
  test "should get transfer" do
    get :transfer
    assert_response :success
  end

  test "should get history" do
    get :history
    assert_response :success
  end

  test "should get exchange" do
    get :exchange
    assert_response :success
  end

end
