require 'test_helper'

class SearchSuggestionsControllerTest < ActionController::TestCase
  test "should get user" do
    get :user
    assert_response :success
  end

end
