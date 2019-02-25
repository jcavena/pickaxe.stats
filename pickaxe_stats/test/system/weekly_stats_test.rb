require "application_system_test_case"

class WeeklyStatsTest < ApplicationSystemTestCase
  setup do
    @weekly_stat = weekly_stats(:one)
  end

  test "visiting the index" do
    visit weekly_stats_url
    assert_selector "h1", text: "Weekly Stats"
  end

  test "creating a Weekly stat" do
    visit weekly_stats_url
    click_on "New Weekly Stat"

    fill_in "Most recent", with: @weekly_stat.most_recent
    click_on "Create Weekly stat"

    assert_text "Weekly stat was successfully created"
    click_on "Back"
  end

  test "updating a Weekly stat" do
    visit weekly_stats_url
    click_on "Edit", match: :first

    fill_in "Most recent", with: @weekly_stat.most_recent
    click_on "Update Weekly stat"

    assert_text "Weekly stat was successfully updated"
    click_on "Back"
  end

  test "destroying a Weekly stat" do
    visit weekly_stats_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Weekly stat was successfully destroyed"
  end
end
