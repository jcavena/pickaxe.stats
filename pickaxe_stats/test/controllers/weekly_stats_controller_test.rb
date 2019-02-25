require 'test_helper'

class WeeklyStatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weekly_stat = weekly_stats(:one)
  end

  test "should get index" do
    get weekly_stats_url
    assert_response :success
  end

  test "should get new" do
    get new_weekly_stat_url
    assert_response :success
  end

  test "should create weekly_stat" do
    assert_difference('WeeklyStat.count') do
      post weekly_stats_url, params: { weekly_stat: { most_recent: @weekly_stat.most_recent } }
    end

    assert_redirected_to weekly_stat_url(WeeklyStat.last)
  end

  test "should show weekly_stat" do
    get weekly_stat_url(@weekly_stat)
    assert_response :success
  end

  test "should get edit" do
    get edit_weekly_stat_url(@weekly_stat)
    assert_response :success
  end

  test "should update weekly_stat" do
    patch weekly_stat_url(@weekly_stat), params: { weekly_stat: { most_recent: @weekly_stat.most_recent } }
    assert_redirected_to weekly_stat_url(@weekly_stat)
  end

  test "should destroy weekly_stat" do
    assert_difference('WeeklyStat.count', -1) do
      delete weekly_stat_url(@weekly_stat)
    end

    assert_redirected_to weekly_stats_url
  end
end
