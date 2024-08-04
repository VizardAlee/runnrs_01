class AddQuantityToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :quantity, :integer, null: true
  end
end
