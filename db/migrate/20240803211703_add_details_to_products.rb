class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :name, :string
    add_column :products, :description, :text
    add_column :products, :price, :decimal, precision: 10, scale: 2
  end
end
