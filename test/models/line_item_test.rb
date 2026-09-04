require "test_helper"

# == Schema Information
#
# Table name: line_items
#
#  id               :integer          not null, primary key
#  quantity         :integer          default(1), not null
#  unit_price_cents :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :integer          not null
#  product_id       :integer          not null
#
# Indexes
#
#  index_line_items_on_order_id    (order_id)
#  index_line_items_on_product_id  (product_id)
#
# Foreign Keys
#
#  order_id    (order_id => orders.id)
#  product_id  (product_id => products.id)
#
class LineItemTest < ActiveSupport::TestCase
  test "requires quantity to be greater than 0" do
    line_item = LineItem.new(order: orders(:one), product: products(:one), quantity: 0, unit_price_cents: 100)
    assert_not line_item.valid?
    assert_includes line_item.errors[:quantity], "must be greater than 0"
  end

  test "requires unit_price_cents to be non-negative" do
    line_item = LineItem.new(order: orders(:one), product: products(:one), quantity: 1, unit_price_cents: -1)
    assert_not line_item.valid?
    assert_includes line_item.errors[:unit_price_cents], "must be greater than or equal to 0"
  end

  test "requires an order and a product" do
    line_item = LineItem.new(quantity: 1, unit_price_cents: 100)
    assert_not line_item.valid?
    assert_includes line_item.errors[:order], "must exist"
    assert_includes line_item.errors[:product], "must exist"
  end

  test "is valid with an order, product, positive quantity, and non-negative price" do
    line_item = LineItem.new(order: orders(:one), product: products(:two), quantity: 2, unit_price_cents: 500)
    assert line_item.valid?
  end
end
