class Product < ApplicationRecord
  belongs_to :store
  has_one_attached :image
  validates :name, :description, :price, presence: true

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
