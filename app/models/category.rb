class Category < ApplicationRecord
  extend Mobility
  include Mixins::Tombstoneable
  include Mixins::Activatable
  
  translates :name, presence: true, type: :string

  has_many :categories_products, class_name: 'CategoryProduct'
  has_many :products, -> { order('categories_products.position ASC') }, through: :categories_products
  has_many_attached :images

  acts_as_list
  default_scope { order(:position) }
end
