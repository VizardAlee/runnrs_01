class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.string :name
      t.references :variation, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
