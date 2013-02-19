class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation

  has_secure_password

  validates :email,                 presence: true, uniqueness: true
  validates :password,              presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  has_many :orders, dependent: :destroy

  # TODO: add 'cart' state for orders and use it on #current_order
  def cart_order
    self.orders.last
  end
end
