class User < ApplicationRecord
  validates :auth0_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validate :terms_and_conditions_true, on: :update

  has_many :carts

  private

  def terms_and_conditions_true
    if terms_and_conditions_changed? && !terms_and_conditions
      errors.add(:terms_and_conditions, "cannot be set to false on update")
    end
  end

end
