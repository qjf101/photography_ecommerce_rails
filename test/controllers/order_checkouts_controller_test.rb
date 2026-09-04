require "test_helper"
require "ostruct"

class OrderCheckoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post cart_items_url, params: { product_id: products(:one).id }
  end

  test "create redirects to cart when cart is empty" do
    delete cart_item_url(CartItem.last)
    post order_checkout_url, params: { email: "guest@example.com" }
    assert_redirected_to cart_path
  end

  test "create redirects to login when a guest uses an email matching an existing account" do
    post order_checkout_url, params: { email: users(:one).email }
    assert_redirected_to login_path
  end

  test "create does not block a logged-in user checking out with their own account email" do
    post login_url, params: { session: { email: users(:one).email, password: "password1" } }

    fake_session = OpenStruct.new(id: "cs_test_789", url: "https://checkout.stripe.com/pay/cs_test_789")
    stub_method(Stripe::Checkout::Session, :create, fake_session) do
      post order_checkout_url, params: {}
    end

    assert_redirected_to fake_session.url
  end

  test "create builds an order with line items and redirects to stripe" do
    fake_session = OpenStruct.new(id: "cs_test_123", url: "https://checkout.stripe.com/pay/cs_test_123")

    assert_difference("Order.count", 1) do
      stub_method(Stripe::Checkout::Session, :create, fake_session) do
        post order_checkout_url, params: { email: "guest@example.com" }
      end
    end

    order = Order.last
    assert_equal 1, order.line_items.count
    assert_equal "cs_test_123", order.stripe_checkout_session_id
    assert_redirected_to fake_session.url
  end

  test "cleans up the order and shows an error when Stripe session creation fails" do
    stripe_error = ->(*) { raise Stripe::StripeError, "network error" }

    assert_no_difference("Order.count") do
      stub_method(Stripe::Checkout::Session, :create, stripe_error) do
        post order_checkout_url, params: { email: "guest@example.com" }
      end
    end

    assert_redirected_to cart_path
  end

  test "create authorizes the new order's confirmation token in the session" do
    fake_session = OpenStruct.new(id: "cs_test_456", url: "https://checkout.stripe.com/pay/cs_test_456")

    stub_method(Stripe::Checkout::Session, :create, fake_session) do
      post order_checkout_url, params: { email: "guest@example.com" }
    end

    order = Order.last
    assert_includes session[:authorized_order_tokens], order.confirmation_token
  end
end
