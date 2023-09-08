class ChangeDefaultDeletedValueInCategories < ActiveRecord::Migration[7.0]
  def change
    change_column_default :categories, :deleted, false
  end
end
