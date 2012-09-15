require 'test_helper'

class SiteAdminControllerTest < ActionController::TestCase
  test "should get add_ad" do
    get :add_ad
    assert_response :success
  end

  test "should get add_deal" do
    get :add_deal
    assert_response :success
  end

  test "should get add_affiliate" do
    get :add_affiliate
    assert_response :success
  end

  test "should get add_vendor" do
    get :add_vendor
    assert_response :success
  end

  test "should get add_metro" do
    get :add_metro
    assert_response :success
  end

  test "should get front_page" do
    get :front_page
    assert_response :success
  end

  test "should get user_admin" do
    get :user_admin
    assert_response :success
  end

  test "should get merchant_admin" do
    get :merchant_admin
    assert_response :success
  end

  test "should get reports" do
    get :reports
    assert_response :success
  end

end
