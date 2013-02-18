class Order < ActiveRecord::Base
  attr_accessible :user_id, :line_items_attributes

  validates  :user_id, presence: true

  belongs_to :user

  has_many :line_items, dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true

  before_validation :mark_zeroed_line_items_for_destruction

  def total
    line_items.map(&:total).sum
  end

  private
  def mark_zeroed_line_items_for_destruction
    line_items.each do |li|
      li.mark_for_destruction if li.quantity.zero?
    end
  end
end
