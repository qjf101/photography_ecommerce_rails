class ChangeCartsUserForeignKeyToNullify < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :carts, :users
    add_foreign_key :carts, :users, on_delete: :nullify
  end
end
