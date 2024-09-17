class AddMessageToNegotiations < ActiveRecord::Migration[7.1]
  def change
    add_column :negotiations, :message, :text, null: false
  end
end
