class Negotiation < ApplicationRecord
  belongs_to :user
  belongs_to :store
  belongs_to :product
  has_many :messages, dependent: :destroy
  has_many :replies, dependent: :destroy
  validates :store_id, presence: true
end
