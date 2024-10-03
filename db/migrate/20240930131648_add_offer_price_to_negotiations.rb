class AddOfferPriceToNegotiations < ActiveRecord::Migration[7.1]
  def change
    add_column :negotiations, :offer_price, :decimal
  end
end
