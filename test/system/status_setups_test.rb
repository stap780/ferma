require "application_system_test_case"

class StatusSetupsTest < ApplicationSystemTestCase
  setup do
    @status_setup = status_setups(:one)
  end

  test "visiting the index" do
    visit status_setups_url
    assert_selector "h1", text: "Status setups"
  end

  test "should create status setup" do
    visit status_setups_url
    click_on "New status setup"

    fill_in "Refgo status", with: @status_setup.refgo_status
    fill_in "Retail status", with: @status_setup.retail_status
    click_on "Create Status setup"

    assert_text "Status setup was successfully created"
    click_on "Back"
  end

  test "should update Status setup" do
    visit status_setup_url(@status_setup)
    click_on "Edit this status setup", match: :first

    fill_in "Refgo status", with: @status_setup.refgo_status
    fill_in "Retail status", with: @status_setup.retail_status
    click_on "Update Status setup"

    assert_text "Status setup was successfully updated"
    click_on "Back"
  end

  test "should destroy Status setup" do
    visit status_setup_url(@status_setup)
    click_on "Destroy this status setup", match: :first

    assert_text "Status setup was successfully destroyed"
  end
end
