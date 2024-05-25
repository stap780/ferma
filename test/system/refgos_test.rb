require "application_system_test_case"

class RefgosTest < ApplicationSystemTestCase
  setup do
    @refgo = refgos(:one)
  end

  test "visiting the index" do
    visit refgos_url
    assert_selector "h1", text: "Refgos"
  end

  test "should create refgo" do
    visit refgos_url
    click_on "New refgo"

    fill_in "Api link", with: @refgo.api_link
    fill_in "Api login", with: @refgo.api_login
    fill_in "Api password", with: @refgo.api_password
    click_on "Create Refgo"

    assert_text "Refgo was successfully created"
    click_on "Back"
  end

  test "should update Refgo" do
    visit refgo_url(@refgo)
    click_on "Edit this refgo", match: :first

    fill_in "Api link", with: @refgo.api_link
    fill_in "Api login", with: @refgo.api_login
    fill_in "Api password", with: @refgo.api_password
    click_on "Update Refgo"

    assert_text "Refgo was successfully updated"
    click_on "Back"
  end

  test "should destroy Refgo" do
    visit refgo_url(@refgo)
    click_on "Destroy this refgo", match: :first

    assert_text "Refgo was successfully destroyed"
  end
end
