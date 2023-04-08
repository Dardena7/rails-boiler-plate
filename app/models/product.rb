class Product < ApplicationRecord
  extend Mobility
  translates :name, presence: true, type: :string

  has_and_belongs_to_many :categories, default: []
end
