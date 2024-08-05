class CreateShoppingCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :shopping_carts do |t|
      t.references :user, null: true, foreign_key: true
      t.string :session_id
      t.string :status

      t.timestamps
    end
  end
end
