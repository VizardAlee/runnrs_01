class AddAgreedPriceToNegotiations < ActiveRecord::Migration[7.1]
  def change
    add_column :negotiations, :agreed_price, :decimal
  end
end
