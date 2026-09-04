require "test_helper"

class OrderLookupsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get order_lookup_url
    assert_response :success
  end
end
