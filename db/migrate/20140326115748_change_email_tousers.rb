class ChangeEmailTousers < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :email, :string, null: true
    change_column_default :users, :email, nil
  end
  
  def down
    change_column :users, :email, :string, null: false
    change_column_default :users, :email, ""
  end
end
