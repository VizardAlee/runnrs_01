class CreateVariations < ActiveRecord::Migration[7.1]
  def change
    create_table :variations do |t|
      t.string :name
      t.references :product, null: false, foreign_key: true
      t.boolean :has_options
      t.integer :quantity

      t.timestamps
    end
  end
end
