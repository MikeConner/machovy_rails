require 'test_helper'

class PromotionImagesControllerTest < ActionController::TestCase
  setup do
    @promotion_image = promotion_images(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:promotion_images)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create promotion_image" do
    assert_difference('PromotionImage.count') do
      post :create, promotion_image: { destination: @promotion_image.destination, name: @promotion_image.name, type: @promotion_image.type }
    end

    assert_redirected_to promotion_image_path(assigns(:promotion_image))
  end

  test "should show promotion_image" do
    get :show, id: @promotion_image
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @promotion_image
    assert_response :success
  end

  test "should update promotion_image" do
    put :update, id: @promotion_image, promotion_image: { destination: @promotion_image.destination, name: @promotion_image.name, type: @promotion_image.type }
    assert_redirected_to promotion_image_path(assigns(:promotion_image))
  end

  test "should destroy promotion_image" do
    assert_difference('PromotionImage.count', -1) do
      delete :destroy, id: @promotion_image
    end

    assert_redirected_to promotion_images_path
  end
end
