class AddAdministratorFamilyNameFirstNameDescriptionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :administrator, :boolean, :default => false, :null => false
    add_column :users, :family_name,   :string
    add_column :users, :first_name,    :string
    add_column :users, :description,   :text
  end
end
