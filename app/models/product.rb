class Product < ApplicationRecord
  after_save :schedule_revert_price, if: :negotiated_price_changed?

  belongs_to :store
  has_one_attached :image
  has_many :variations, dependent: :destroy

  has_many :line_items
  has_many :orders, through: :order_items
  has_many :order_items, through: :line_items
  has_many :negotiations, dependent: :destroy

  def schedule_revert_price
    # Set a background job to revert the price after 24 hours
    if negotiation_expires_at.present?
      RevertPriceJob.set(wait_until: negotiation_expires_at).perform_later(self)
    end
  end

  def revert_to_default_price
    update(negotiated_price: nil, negotiation_expires_at: nil)
  end

  validates :name, :description, :price, presence: true
  validates :store, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
