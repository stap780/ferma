require "test_helper"

class RetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retail = retails(:one)
  end

  test "should get index" do
    get retails_url
    assert_response :success
  end

  test "should get new" do
    get new_retail_url
    assert_response :success
  end

  test "should create retail" do
    assert_difference("Retail.count") do
      post retails_url, params: { retail: { api_key: @retail.api_key, api_link: @retail.api_link } }
    end

    assert_redirected_to retail_url(Retail.last)
  end

  test "should show retail" do
    get retail_url(@retail)
    assert_response :success
  end

  test "should get edit" do
    get edit_retail_url(@retail)
    assert_response :success
  end

  test "should update retail" do
    patch retail_url(@retail), params: { retail: { api_key: @retail.api_key, api_link: @retail.api_link } }
    assert_redirected_to retail_url(@retail)
  end

  test "should destroy retail" do
    assert_difference("Retail.count", -1) do
      delete retail_url(@retail)
    end

    assert_redirected_to retails_url
  end
end
