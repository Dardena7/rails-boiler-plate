class User < ApplicationRecord
  validates :auth0_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
