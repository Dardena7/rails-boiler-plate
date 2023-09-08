module Mixins::Activatable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false)}
  end

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attribute(:active, false)
  end
end