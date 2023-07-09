class Category < ApplicationRecord
  extend Mobility
  translates :name, presence: true, type: :string

  has_many :categories_products, class_name: 'CategoryProduct'
  has_many :products, -> { order('categories_products.position ASC') }, through: :categories_products

  acts_as_list
  default_scope { order(:position) }
end
