require "application_system_test_case"

class RetailsTest < ApplicationSystemTestCase
  setup do
    @retail = retails(:one)
  end

  test "visiting the index" do
    visit retails_url
    assert_selector "h1", text: "Retails"
  end

  test "should create retail" do
    visit retails_url
    click_on "New retail"

    fill_in "Api key", with: @retail.api_key
    fill_in "Api link", with: @retail.api_link
    click_on "Create Retail"

    assert_text "Retail was successfully created"
    click_on "Back"
  end

  test "should update Retail" do
    visit retail_url(@retail)
    click_on "Edit this retail", match: :first

    fill_in "Api key", with: @retail.api_key
    fill_in "Api link", with: @retail.api_link
    click_on "Update Retail"

    assert_text "Retail was successfully updated"
    click_on "Back"
  end

  test "should destroy Retail" do
    visit retail_url(@retail)
    click_on "Destroy this retail", match: :first

    assert_text "Retail was successfully destroyed"
  end
end
