class Product < ApplicationRecord
  extend Mobility
  translates :name, presence: true, type: :string

  has_many :categories_products, class_name: 'CategoryProduct'
  has_many :categories, -> { order('categories_products.position ASC') }, through: :categories_products
  has_many_attached :images
end
