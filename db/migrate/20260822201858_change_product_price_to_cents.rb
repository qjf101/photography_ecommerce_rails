class ChangeProductPriceToCents < ActiveRecord::Migration[8.1]
  def change
    remove_column :products, :price, :decimal
    add_column :products, :price_cents, :integer, null: false, default: 0
  end
end
