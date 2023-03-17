class ChangeFirstnameAndLastnameDefaultValues < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :firstname, ""
    change_column_default :users, :lastname, ""
  end
end
