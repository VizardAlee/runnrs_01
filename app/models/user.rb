class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { regular: 0, store_owner: 1 }
  has_one :store

  def can_create_store?
    role == 'store_owner' && store.nil?
  end

  def has_store?
    store.present?
  end
end
