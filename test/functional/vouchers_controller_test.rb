require 'test_helper'

class VouchersControllerTest < ActionController::TestCase
  setup do
    @voucher = vouchers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vouchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create voucher" do
    assert_difference('Voucher.count') do
      post :create, voucher: { expiration_date: @voucher.expiration_date, issue_date: @voucher.issue_date, notes: @voucher.notes, order_id: @voucher.order_id, promotion_id: @voucher.promotion_id, redemption_date: @voucher.redemption_date, status: @voucher.status, user_id: @voucher.user_id, uuid: @voucher.uuid }
    end

    assert_redirected_to voucher_path(assigns(:voucher))
  end

  test "should show voucher" do
    get :show, id: @voucher
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @voucher
    assert_response :success
  end

  test "should update voucher" do
    put :update, id: @voucher, voucher: { expiration_date: @voucher.expiration_date, issue_date: @voucher.issue_date, notes: @voucher.notes, order_id: @voucher.order_id, promotion_id: @voucher.promotion_id, redemption_date: @voucher.redemption_date, status: @voucher.status, user_id: @voucher.user_id, uuid: @voucher.uuid }
    assert_redirected_to voucher_path(assigns(:voucher))
  end

  test "should destroy voucher" do
    assert_difference('Voucher.count', -1) do
      delete :destroy, id: @voucher
    end

    assert_redirected_to vouchers_path
  end
end
