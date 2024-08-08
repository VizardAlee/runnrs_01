class ShoppingCart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :line_items, dependent: :destroy
  has_one :order

  def subtotal
    line_items.sum(&:total_price)
  end

  def total
    subtotal # You can add shipping or tax calculations here later
  end
end
