class Category < ApplicationRecord
  extend Mobility
  translates :name, presence: true, type: :string

  has_and_belongs_to_many :products, default: []
end
