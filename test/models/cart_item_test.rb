require "test_helper"

# == Schema Information
#
# Table name: cart_items
#
#  id         :integer          not null, primary key
#  quantity   :integer          default(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :integer          not null
#  product_id :integer          not null
#
# Indexes
#
#  index_cart_items_on_cart_id                 (cart_id)
#  index_cart_items_on_cart_id_and_product_id  (cart_id,product_id) UNIQUE
#  index_cart_items_on_product_id              (product_id)
#
# Foreign Keys
#
#  cart_id     (cart_id => carts.id)
#  product_id  (product_id => products.id)
#
class CartItemTest < ActiveSupport::TestCase
  test "requires quantity to be greater than 0" do
    cart_item = CartItem.new(cart: carts(:one), product: products(:two), quantity: 0)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:quantity], "must be greater than 0"
  end

  test "requires a cart and a product" do
    cart_item = CartItem.new(quantity: 1)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:cart], "must exist"
    assert_includes cart_item.errors[:product], "must exist"
  end

  test "cannot have two cart items for the same product in the same cart" do
    existing = cart_items(:one)
    duplicate = CartItem.new(cart: existing.cart, product: existing.product, quantity: 1)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save! }
  end
end
