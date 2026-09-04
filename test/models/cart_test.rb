require "test_helper"

# == Schema Information
#
# Table name: carts
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_carts_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id) ON DELETE => nullify
#
class CartTest < ActiveSupport::TestCase
  test "can be created without a user" do
    cart = Cart.new
    assert cart.valid?
  end

  test "destroying a cart destroys its cart items" do
    cart = carts(:one)
    assert_difference("CartItem.count", -cart.cart_items.count) do
      cart.destroy
    end
  end

  test "total_cents sums quantity times product price across cart items" do
    cart = Cart.create!
    product_a = Product.create!(name: "Print A", price_cents: 1000)
    product_b = Product.create!(name: "Print B", price_cents: 2500)
    cart.cart_items.create!(product: product_a, quantity: 2)
    cart.cart_items.create!(product: product_b, quantity: 1)

    assert_equal 4500, cart.total_cents
  end
end
