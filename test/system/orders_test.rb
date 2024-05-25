require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
  end

  test "visiting the index" do
    visit orders_url
    assert_selector "h1", text: "Orders"
  end

  test "should create order" do
    visit orders_url
    click_on "New order"

    fill_in "Delivery price", with: @order.delivery_price
    fill_in "Items info", with: @order.items_info
    check "Prepaid" if @order.prepaid
    fill_in "Refgo num", with: @order.refgo_num
    fill_in "Retail client uid", with: @order.retail_client_uid
    fill_in "Retail uid", with: @order.retail_uid
    fill_in "Storage code", with: @order.storage_code
    fill_in "Sum", with: @order.sum
    click_on "Create Order"

    assert_text "Order was successfully created"
    click_on "Back"
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit this order", match: :first

    fill_in "Delivery price", with: @order.delivery_price
    fill_in "Items info", with: @order.items_info
    check "Prepaid" if @order.prepaid
    fill_in "Refgo num", with: @order.refgo_num
    fill_in "Retail client uid", with: @order.retail_client_uid
    fill_in "Retail uid", with: @order.retail_uid
    fill_in "Storage code", with: @order.storage_code
    fill_in "Sum", with: @order.sum
    click_on "Update Order"

    assert_text "Order was successfully updated"
    click_on "Back"
  end

  test "should destroy Order" do
    visit order_url(@order)
    click_on "Destroy this order", match: :first

    assert_text "Order was successfully destroyed"
  end
end
