class ChangeAdminDefaultOnUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :admin, from: nil, to: false
    change_column_null :users, :admin, false, false
  end
end
