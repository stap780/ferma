require "test_helper"

class RefgosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @refgo = refgos(:one)
  end

  test "should get index" do
    get refgos_url
    assert_response :success
  end

  test "should get new" do
    get new_refgo_url
    assert_response :success
  end

  test "should create refgo" do
    assert_difference("Refgo.count") do
      post refgos_url, params: { refgo: { api_link: @refgo.api_link, api_login: @refgo.api_login, api_password: @refgo.api_password } }
    end

    assert_redirected_to refgo_url(Refgo.last)
  end

  test "should show refgo" do
    get refgo_url(@refgo)
    assert_response :success
  end

  test "should get edit" do
    get edit_refgo_url(@refgo)
    assert_response :success
  end

  test "should update refgo" do
    patch refgo_url(@refgo), params: { refgo: { api_link: @refgo.api_link, api_login: @refgo.api_login, api_password: @refgo.api_password } }
    assert_redirected_to refgo_url(@refgo)
  end

  test "should destroy refgo" do
    assert_difference("Refgo.count", -1) do
      delete refgo_url(@refgo)
    end

    assert_redirected_to refgos_url
  end
end
