class AddDefaultValueToFulfilled < ActiveRecord::Migration[7.1]
  def change
    change_column_default :orders, :fulfilled, from: nil, to: false 
  end
end
