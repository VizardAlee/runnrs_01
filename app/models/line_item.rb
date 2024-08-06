class LineItem < ApplicationRecord
  belongs_to :shopping_cart
  belongs_to :product
  belongs_to :variation
end
