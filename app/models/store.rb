class Store < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  # has_many :orders, through: :products
  has_one_attached :logo

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
