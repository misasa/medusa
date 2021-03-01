class CreateReferrings < ActiveRecord::Migration[4.2]
  def change
    create_table :referrings do |t|
      t.integer :bib_id
      t.integer :referable_id
      t.string  :referable_type
      
      t.timestamps
    end
    
    add_index :referrings, :bib_id
    add_index :referrings, :referable_id
  end
end
