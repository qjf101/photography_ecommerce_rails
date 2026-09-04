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
class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
end
