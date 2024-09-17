class Product < ApplicationRecord
  belongs_to :store
  has_one_attached :image
  has_many :variations, dependent: :destroy

  has_many :line_items
  has_many :orders, through: :order_items
  has_many :order_items, through: :line_items
  has_many :negotiations, dependent: :destroy


  validates :name, :description, :price, presence: true
  validates :store, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
