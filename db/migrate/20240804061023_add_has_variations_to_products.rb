class AddHasVariationsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :has_variations, :boolean, default: false
  end
end
