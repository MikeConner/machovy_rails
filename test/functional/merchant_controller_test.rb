require 'test_helper'

class MerchantControllerTest < ActionController::TestCase
  test "should get MyDeals" do
    get :MyDeals
    assert_response :success
  end

  test "should get reports" do
    get :reports
    assert_response :success
  end

  test "should get payments" do
    get :payments
    assert_response :success
  end

  test "should get dashboard" do
    get :dashboard
    assert_response :success
  end

end
