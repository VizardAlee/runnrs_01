class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :negotiation

  validates :message, presence: true
end
