require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    @order.regenerate_confirmation_token
    post order_lookup_url, params: { email: @order.email, confirmation_token: @order.confirmation_token }
  end

  test "should get show" do
    get order_url(@order)
    assert_response :success
  end

  test "can request a refund on a paid order" do
    @order.update!(status: "paid")
    patch request_refund_order_url(@order)
    assert_equal "refund_pending", @order.reload.status
    assert_redirected_to order_url(@order)
  end

  test "can request a refund on a completed order" do
    @order.update!(status: "completed")
    patch request_refund_order_url(@order)
    assert_equal "refund_pending", @order.reload.status
  end

  test "cannot request a refund on a pending order" do
    @order.update!(status: "pending")
    patch request_refund_order_url(@order)
    assert_equal "pending", @order.reload.status
    assert_redirected_to order_url(@order)
  end

  test "cannot request a refund on an already-refunded order" do
    @order.update!(status: "refunded")
    patch request_refund_order_url(@order)
    assert_equal "refunded", @order.reload.status
  end

  test "a logged-in owner can view their order without the guest lookup flow" do
    order = orders(:two)
    order.regenerate_confirmation_token
    order.update!(user: users(:one))

    post login_url, params: { session: { email: users(:one).email, password: "password1" } }
    get order_url(order)

    assert_response :success
  end

  test "a logged-in user who does not own the order and never looked it up is redirected" do
    order = orders(:two)
    order.regenerate_confirmation_token
    order.update!(user: users(:one))

    post login_url, params: { session: { email: users(:two).email, password: "password2" } }
    get order_url(order)

    assert_redirected_to order_lookup_path
  end

  test "an unknown token redirects the same way as an unauthorized one" do
    get order_url("nonexistent-token")
    assert_redirected_to order_lookup_path
  end
end
