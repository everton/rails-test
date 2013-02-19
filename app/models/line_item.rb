class LineItem < ActiveRecord::Base
  attr_accessible :product_id, :quantity

  belongs_to :product
  belongs_to :order

  validates :product_id, presence: true
  validates :quantity,   presence: true, numericality: {
    greater_than: 0
  }

  before_create :take_current_price

  def total
    self.price * self.quantity
  end

  private
  def take_current_price
    self.price = self.product.price
  end
end
