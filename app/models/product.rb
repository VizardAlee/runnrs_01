class Product < ApplicationRecord
  belongs_to :store
  has_one_attached :image  # Add this line
  validates :name, :description, :price, presence: true
end
