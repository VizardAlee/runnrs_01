class Negotiation < ApplicationRecord
  belongs_to :user
  belongs_to :store
  belongs_to :product
  belongs_to :shop_owner, class_name: 'User', foreign_key: 'shop_owner_id'
  has_many :messages, dependent: :destroy
  has_many :replies, dependent: :destroy

  validates :store_id, presence: true
  validates :agreed_price, numericality: { greater_than: 0 }, allow_nil: true
end
