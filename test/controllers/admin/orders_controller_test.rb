require "test_helper"
require "ostruct"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Order.find_each(&:regenerate_confirmation_token)
    @order = orders(:one)
    @order.update!(status: "paid", stripe_payment_intent_id: "pi_test_123")
  end

  test "redirects guests away from the order list" do
    get admin_orders_url
    assert_redirected_to root_path
  end

  test "redirects logged-in non-admins away too" do
    sign_in(users(:one), "password1")
    get admin_orders_url
    assert_redirected_to root_path
  end

  test "allows an admin to view the order list" do
    sign_in_as_admin
    get admin_orders_url
    assert_response :success
  end

  test "does not list orders that never got a Stripe checkout session" do
    phantom = Order.create!(email: "phantom@example.com")

    sign_in_as_admin
    get admin_orders_url

    assert_no_match phantom.confirmation_token, response.body
  end

  test "does not list an order that reached Stripe but is still pending confirmation" do
    pending_order = Order.create!(email: "guest@example.com", stripe_checkout_session_id: "cs_test_still_pending")

    sign_in_as_admin
    get admin_orders_url

    assert_no_match pending_order.confirmation_token, response.body
  end

  test "allows an admin to view a single order" do
    sign_in_as_admin
    get admin_order_url(@order)
    assert_response :success
  end

  test "allows an admin to mark a paid order completed" do
    sign_in_as_admin
    patch complete_admin_order_url(@order)
    assert_equal "completed", @order.reload.status
    assert_redirected_to admin_order_url(@order)
  end

  test "allows an admin to refund a paid order" do
    sign_in_as_admin
    fake_refund = OpenStruct.new(id: "re_test_123")

    stub_method(Stripe::Refund, :create, fake_refund) do
      patch refund_admin_order_url(@order)
    end

    assert_equal "refunded", @order.reload.status
    assert_redirected_to admin_order_url(@order)
  end

  test "does not call Stripe again for an order that is already refunded" do
    sign_in_as_admin
    @order.update!(status: "refunded")

    stub_method(Stripe::Refund, :create, ->(*) { raise "should not be called" }) do
      patch refund_admin_order_url(@order)
    end

    assert_redirected_to admin_order_url(@order)
  end

  test "shows an error and leaves the status unchanged when the Stripe refund fails" do
    sign_in_as_admin
    stripe_error = ->(*) { raise Stripe::StripeError, "card issuer declined" }

    stub_method(Stripe::Refund, :create, stripe_error) do
      patch refund_admin_order_url(@order)
    end

    assert_equal "paid", @order.reload.status
    assert_redirected_to admin_order_url(@order)
  end

  private

  def sign_in_as_admin
    sign_in(users(:admin), "adminpass1")
  end

  def sign_in(user, password)
    post login_url, params: { session: { email: user.email, password: password } }
  end
end
