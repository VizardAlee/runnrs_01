class AddFulfilledToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :fulfilled, :boolean
  end
end
