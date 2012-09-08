require 'test_helper'

class PromotionsControllerTest < ActionController::TestCase
  setup do
    @promotion = promotions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:promotions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create promotion" do
    assert_difference('Promotion.count') do
      post :create, promotion: { description: @promotion.description, destination: @promotion.destination, end: @promotion.end, grid_weight: @promotion.grid_weight, limitations: @promotion.limitations, metro_id: @promotion.metro_id, price: @promotion.price, quantity: @promotion.quantity, retail_value: @promotion.retail_value, revenue_shared: @promotion.revenue_shared, start: @promotion.start, teaser_image: @promotion.teaser_image, title: @promotion.title, vendor_id: @promotion.vendor_id, voucher_instructions: @promotion.voucher_instructions }
    end

    assert_redirected_to promotion_path(assigns(:promotion))
  end

  test "should show promotion" do
    get :show, id: @promotion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @promotion
    assert_response :success
  end

  test "should update promotion" do
    put :update, id: @promotion, promotion: { description: @promotion.description, destination: @promotion.destination, end: @promotion.end, grid_weight: @promotion.grid_weight, limitations: @promotion.limitations, metro_id: @promotion.metro_id, price: @promotion.price, quantity: @promotion.quantity, retail_value: @promotion.retail_value, revenue_shared: @promotion.revenue_shared, start: @promotion.start, teaser_image: @promotion.teaser_image, title: @promotion.title, vendor_id: @promotion.vendor_id, voucher_instructions: @promotion.voucher_instructions }
    assert_redirected_to promotion_path(assigns(:promotion))
  end

  test "should destroy promotion" do
    assert_difference('Promotion.count', -1) do
      delete :destroy, id: @promotion
    end

    assert_redirected_to promotions_path
  end
end
