class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :shopping_cart
  has_many :order_items
  has_many :line_items, through: :order_items
  has_many :products, through: :order_items

  validates :shipping_address, presence: true
  validates :billing_address, presence: true
  validates :payment_method, presence: true
end
