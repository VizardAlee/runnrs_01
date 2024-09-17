class CreateNegotiations < ActiveRecord::Migration[7.1]
  def change
    create_table :negotiations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
