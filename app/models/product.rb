class Product < ActiveRecord::Base
  attr_accessible :description, :price, :name, :image

  has_attached_file :image, default_style: :medium,
    path: ':rails_root/public/p/:id/:style/:basename.:extension',
    url: '/p/:id/:style/:basename.:extension', styles: {
      medium: ['300x225>', 'jpeg'], thumb: ['100x75>', 'jpeg']
    }

  validates :name,             presence: true, uniqueness: true
  validates :price,            presence: true
  validates :description,      presence: true

  validates_attachment :image, presence: true
end
