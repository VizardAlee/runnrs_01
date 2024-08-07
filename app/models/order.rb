class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shopping_cart
end
