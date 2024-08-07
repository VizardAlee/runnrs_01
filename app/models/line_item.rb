class LineItem < ApplicationRecord
  belongs_to :shopping_cart
  belongs_to :product
  belongs_to :variation

  def total_price
    quantity * price
  end

  def formatted_price
    number_to_currency(price, unit: "₦")
  end

  def formatted_total_price
    number_to_currency(total_price, unit: "₦")
  end

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
