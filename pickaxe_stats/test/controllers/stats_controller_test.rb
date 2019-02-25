require 'test_helper'

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get general" do
    get stats_general_url
    assert_response :success
  end

  test "should get travel" do
    get stats_travel_url
    assert_response :success
  end

  test "should get food" do
    get stats_food_url
    assert_response :success
  end

  test "should get kills" do
    get stats_kills_url
    assert_response :success
  end

  test "should get mining" do
    get stats_mining_url
    assert_response :success
  end

  test "should get crafting" do
    get stats_crafting_url
    assert_response :success
  end

  test "should get achievements" do
    get stats_achievements_url
    assert_response :success
  end

  test "should get adventuring_time" do
    get stats_adventuring_time_url
    assert_response :success
  end

end
