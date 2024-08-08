class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :shopping_cart

  validates :shipping_address, presence: true
  validates :billing_address, presence: true
  validates :payment_method, presence: true
end
