class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :line_item
  belongs_to :product

  validates :quantity, :price, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
