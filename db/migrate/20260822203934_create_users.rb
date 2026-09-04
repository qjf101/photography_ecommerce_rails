class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.boolean :admin
      t.string :password_digest
      t.string :stripe_customer_id

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
