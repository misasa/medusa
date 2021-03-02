class CreateClassifications < ActiveRecord::Migration[4.2]
  def change
    create_table :classifications do |t|
      t.string  :name
      t.string  :full_name
      t.text    :description
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
    end
    
    add_index :classifications, :parent_id
  end
end
