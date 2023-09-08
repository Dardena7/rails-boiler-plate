class Product < ApplicationRecord
  extend Mobility
  include Mixins::Tombstoneable
  include Mixins::Activatable

  translates :name, presence: true, type: :string

  has_many :categories_products, class_name: 'CategoryProduct'
  has_many :categories, -> { order('categories_products.position ASC') }, through: :categories_products
  has_many_attached :images
  default_scope { i18n }
end
