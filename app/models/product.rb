class Product < ActiveRecord::Base
  attr_accessible :description, :price, :name

  validates :name,        presence: true, uniqueness: true
  validates :price,       presence: true
  validates :description, presence: true
end
