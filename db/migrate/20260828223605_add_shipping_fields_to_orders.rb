class AddShippingFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :shipping_name, :string
    add_column :orders, :shipping_address_line1, :string
    add_column :orders, :shipping_address_line2, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_state, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_country, :string
  end
end
