class ChangePriceColumnInProducts < ActiveRecord::Migration[7.1]
  def change
    change_column :products, :price, :numeric, precision: 15, scale: 2
  end
end
