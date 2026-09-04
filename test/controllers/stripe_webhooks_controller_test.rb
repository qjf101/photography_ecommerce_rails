require "test_helper"
require "ostruct"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    @order.update!(stripe_checkout_session_id: "cs_test_123")
  end

  test "invalid signature returns bad_request" do
    post stripe_webhooks_url, params: { foo: "bar" }, headers: { "Stripe-Signature" => "invalid" }
    assert_response :bad_request
  end

  test "checkout.session.completed marks the order paid, syncs total_cents, and stores shipping info" do
    shipping_address = OpenStruct.new(line1: "123 Main St", line2: nil, city: "Raleigh", state: "NC", postal_code: "27616", country: "US")
    shipping_details = OpenStruct.new(name: "Jane Doe", address: shipping_address)
    collected_information = OpenStruct.new(shipping_details: shipping_details)
    session_object = OpenStruct.new(id: "cs_test_123", amount_total: 4500, collected_information: collected_information)
    event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session_object))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    @order.reload
    assert_equal "paid", @order.status
    assert_equal 4500, @order.total_cents
    assert_equal "Jane Doe", @order.shipping_name
    assert_equal "123 Main St", @order.shipping_address_line1
    assert_response :ok
  end

  test "checkout.session.completed destroys the order's cart" do
    cart = carts(:one)
    @order.update!(cart: cart)

    session_object = OpenStruct.new(
      id: "cs_test_123",
      amount_total: 4500,
      collected_information: OpenStruct.new(shipping_details: nil)
    )
    event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session_object))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_raises(ActiveRecord::RecordNotFound) { cart.reload }
  end

  test "checkout.session.expired marks the order failed" do
    session_object = OpenStruct.new(id: "cs_test_123")
    event = OpenStruct.new(type: "checkout.session.expired", data: OpenStruct.new(object: session_object))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_equal "failed", @order.reload.status
  end

  test "unrecognized event types are acknowledged without error" do
    event = OpenStruct.new(type: "some.other.event", data: OpenStruct.new(object: OpenStruct.new))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_response :ok
  end

  test "charge.refunded marks the order refunded when fully refunded" do
    @order.update!(status: "paid", stripe_payment_intent_id: "pi_test_123")
    charge = OpenStruct.new(payment_intent: "pi_test_123", refunded: true)
    event = OpenStruct.new(type: "charge.refunded", data: OpenStruct.new(object: charge))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_equal "refunded", @order.reload.status
    assert_response :ok
  end

  test "charge.refunded does not mark the order refunded when only partially refunded" do
    @order.update!(status: "paid", stripe_payment_intent_id: "pi_test_123")
    charge = OpenStruct.new(payment_intent: "pi_test_123", refunded: false)
    event = OpenStruct.new(type: "charge.refunded", data: OpenStruct.new(object: charge))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_equal "paid", @order.reload.status
  end

  test "charge.refunded with an unknown payment_intent does not raise" do
    charge = OpenStruct.new(payment_intent: "pi_nonexistent", refunded: true)
    event = OpenStruct.new(type: "charge.refunded", data: OpenStruct.new(object: charge))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_response :ok
  end

  test "an unknown checkout session id does not raise" do
    session_object = OpenStruct.new(
      id: "cs_nonexistent",
      amount_total: 1000,
      collected_information: OpenStruct.new(shipping_details: nil)
    )
    event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session_object))

    stub_method(Stripe::Webhook, :construct_event, event) do
      post stripe_webhooks_url, headers: { "Stripe-Signature" => "any" }
    end

    assert_response :ok
  end
end
