class ChangeOrdersUserForeignKeyToNullify < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :orders, :users
    add_foreign_key :orders, :users, on_delete: :nullify
  end
end
