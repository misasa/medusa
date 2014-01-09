class CreateProjectMembers < ActiveRecord::Migration
  def change
    create_table :project_members do |t|
      t.integer :project_id, :null => false
      t.integer :user_id, :null => false
    end
    
    add_index :project_members, :project_id
    add_index :project_members, :user_id
  end
end
