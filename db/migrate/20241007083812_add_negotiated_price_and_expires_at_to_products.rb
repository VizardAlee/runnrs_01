class AddNegotiatedPriceAndExpiresAtToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :negotiated_price, :decimal, precision: 10, scale: 2
    add_column :products, :negotiation_expires_at, :datetime
  end
end
