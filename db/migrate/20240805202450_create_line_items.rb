class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.references :shopping_cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :variation, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
