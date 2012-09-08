require 'test_helper'

class VendorsControllerTest < ActionController::TestCase
  setup do
    @vendor = vendors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vendors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vendor" do
    assert_difference('Vendor.count') do
      post :create, vendor: { address_1: @vendor.address_1, address_2: @vendor.address_2, city: @vendor.city, fbook: @vendor.fbook, name: @vendor.name, phone: @vendor.phone, state: @vendor.state, url: @vendor.url, zip: @vendor.zip }
    end

    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should show vendor" do
    get :show, id: @vendor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vendor
    assert_response :success
  end

  test "should update vendor" do
    put :update, id: @vendor, vendor: { address_1: @vendor.address_1, address_2: @vendor.address_2, city: @vendor.city, fbook: @vendor.fbook, name: @vendor.name, phone: @vendor.phone, state: @vendor.state, url: @vendor.url, zip: @vendor.zip }
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should destroy vendor" do
    assert_difference('Vendor.count', -1) do
      delete :destroy, id: @vendor
    end

    assert_redirected_to vendors_path
  end
end
