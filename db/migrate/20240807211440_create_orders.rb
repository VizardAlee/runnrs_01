class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shopping_cart, null: false, foreign_key: true
      t.decimal :total
      t.string :status
      t.text :shipping_address
      t.text :billing_address
      t.string :payment_method

      t.timestamps
    end
  end
end
