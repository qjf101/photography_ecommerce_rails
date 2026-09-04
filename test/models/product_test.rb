require "test_helper"

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
class ProductTest < ActiveSupport::TestCase
  test "requires a name" do
    product = Product.new(price_cents: 500)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "requires price_cents to be present and non-negative" do
    product = Product.new(name: "Test Print", price_cents: -1)
    assert_not product.valid?
    assert_includes product.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "is valid with a name and non-negative price_cents" do
    product = Product.new(name: "Test Print", price_cents: 0)
    assert product.valid?
  end

  test "active scope only returns active products" do
    inactive = Product.create!(name: "Discontinued Print", price_cents: 500, active: false)
    assert_includes Product.active, products(:one)
    assert_not_includes Product.active, inactive
  end

  test "cannot be destroyed while it has line items" do
    product = products(:one)
    assert_not product.destroy
    assert_not product.errors[:base].empty?
  end

  test "can be destroyed when it has no line items" do
    product = Product.create!(name: "Unpurchased Print", price_cents: 500)
    assert product.destroy
  end
end
