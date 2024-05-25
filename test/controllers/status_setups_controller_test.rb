require "test_helper"

class StatusSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status_setup = status_setups(:one)
  end

  test "should get index" do
    get status_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_status_setup_url
    assert_response :success
  end

  test "should create status_setup" do
    assert_difference("StatusSetup.count") do
      post status_setups_url, params: { status_setup: { refgo_status: @status_setup.refgo_status, retail_status: @status_setup.retail_status } }
    end

    assert_redirected_to status_setup_url(StatusSetup.last)
  end

  test "should show status_setup" do
    get status_setup_url(@status_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_status_setup_url(@status_setup)
    assert_response :success
  end

  test "should update status_setup" do
    patch status_setup_url(@status_setup), params: { status_setup: { refgo_status: @status_setup.refgo_status, retail_status: @status_setup.retail_status } }
    assert_redirected_to status_setup_url(@status_setup)
  end

  test "should destroy status_setup" do
    assert_difference("StatusSetup.count", -1) do
      delete status_setup_url(@status_setup)
    end

    assert_redirected_to status_setups_url
  end
end
