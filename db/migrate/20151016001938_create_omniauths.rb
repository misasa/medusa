class CreateOmniauths < ActiveRecord::Migration
  def change
    create_table :omniauths do |t|
      t.integer :user_id, null: false
      t.string :provider, null: false
      t.string :uid, null: false
      t.timestamps
    end
    
    add_index :omniauths, [:provider, :uid], unique: true
  end
end
