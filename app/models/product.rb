# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  active      :boolean          default(TRUE), not null
#  name        :string
#  price_cents :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Product < ApplicationRecord
    validates :name, presence: true
    validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, allow_nil: false }

    has_many_attached :images
    has_many :cart_items
    has_many :line_items, dependent: :restrict_with_error

    scope :active, -> { where(active: true) }
end
