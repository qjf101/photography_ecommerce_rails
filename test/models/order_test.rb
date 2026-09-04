require "test_helper"

# == Schema Information
#
# Table name: orders
#
#  id                         :integer          not null, primary key
#  confirmation_token         :string
#  email                      :string           not null
#  shipping_address_line1     :string
#  shipping_address_line2     :string
#  shipping_city              :string
#  shipping_country           :string
#  shipping_name              :string
#  shipping_postal_code       :string
#  shipping_state             :string
#  status                     :string           default("pending"), not null
#  total_cents                :integer          default(0), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cart_id                    :integer
#  stripe_checkout_session_id :string
#  stripe_payment_intent_id   :string
#  user_id                    :integer
#
# Indexes
#
#  index_orders_on_cart_id                     (cart_id)
#  index_orders_on_confirmation_token          (confirmation_token) UNIQUE
#  index_orders_on_stripe_checkout_session_id  (stripe_checkout_session_id) UNIQUE
#  index_orders_on_user_id                     (user_id)
#
# Foreign Keys
#
#  cart_id  (cart_id => carts.id) ON DELETE => nullify
#  user_id  (user_id => users.id) ON DELETE => nullify
#
class OrderTest < ActiveSupport::TestCase
  test "generates a confirmation_token on create" do
    order = Order.create!(email: "guest@example.com")
    assert order.confirmation_token.present?
  end

  test "requires an email" do
    order = Order.new
    assert_not order.valid?
    assert_includes order.errors[:email], "can't be blank"
  end

  test "requires a valid email format" do
    order = Order.new(email: "not-an-email")
    assert_not order.valid?
    assert_includes order.errors[:email], "must be a valid email address"
  end

  test "does not require email uniqueness across orders" do
    order = Order.create!(email: orders(:one).email)
    assert order.persisted?
  end

  test "normalizes email to a stripped, downcased value" do
    order = Order.create!(email: "  Guest@Example.com  ")
    assert_equal "guest@example.com", order.email
  end

  test "defaults to pending status" do
    order = Order.create!(email: "guest@example.com")
    assert order.pending?
  end

  test "can be created without a user or a cart" do
    order = Order.new(email: "guest@example.com")
    assert order.valid?
  end

  test "to_param returns the confirmation_token, not the id" do
    order = orders(:one)
    order.regenerate_confirmation_token
    assert_equal order.confirmation_token, order.to_param
  end
end
