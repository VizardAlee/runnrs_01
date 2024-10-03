class AddShopOwnerIdToNegotiations < ActiveRecord::Migration[7.1]
  def change
    add_column :negotiations, :shop_owner_id, :integer
  end
end
