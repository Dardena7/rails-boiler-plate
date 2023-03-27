class Product < ApplicationRecord
  extend Mobility
  translates :name, type: :string
end
