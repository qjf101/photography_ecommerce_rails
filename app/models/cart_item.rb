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
class CartItem < ApplicationRecord
  validates :quantity, numericality: { greater_than: 0 }

  belongs_to :cart
  belongs_to :product
end
