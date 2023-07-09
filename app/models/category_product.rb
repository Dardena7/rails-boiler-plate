class CategoryProduct < ApplicationRecord
  self.table_name = "categories_products"
  belongs_to :category
  belongs_to :product

  acts_as_list scope: :category
end