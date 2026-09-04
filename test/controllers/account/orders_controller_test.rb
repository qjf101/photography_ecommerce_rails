require "test_helper"

class Account::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to login" do
    get account_orders_url
    assert_redirected_to login_path
  end

  test "shows only the logged-in user's own orders" do
    orders(:one).update!(status: "paid")
    orders(:one).regenerate_confirmation_token
    orders(:two).regenerate_confirmation_token

    sign_in(users(:one), "password1")
    get account_orders_url

    assert_response :success
    assert_match orders(:one).confirmation_token, response.body
    assert_no_match orders(:two).confirmation_token, response.body
  end

  test "does not show orders that never got a Stripe checkout session" do
    orders(:one).update!(status: "paid")
    orders(:one).regenerate_confirmation_token
    phantom = Order.create!(email: users(:one).email, user: users(:one))

    sign_in(users(:one), "password1")
    get account_orders_url

    assert_no_match phantom.confirmation_token, response.body
  end

  test "does not show an order that reached Stripe but is still pending confirmation" do
    pending_order = Order.create!(email: users(:one).email, user: users(:one), stripe_checkout_session_id: "cs_test_still_pending")

    sign_in(users(:one), "password1")
    get account_orders_url

    assert_response :success
    assert_no_match pending_order.confirmation_token, response.body
  end

  test "shows an empty state when the user has no orders" do
    sign_in(users(:admin), "adminpass1")
    get account_orders_url

    assert_response :success
    assert_match "haven't placed any orders", response.body
  end

  private

  def sign_in(user, password)
    post login_url, params: { session: { email: user.email, password: password } }
  end
end
