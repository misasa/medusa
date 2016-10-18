class AddAccessTokenToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :staff_id, comment: "職員ID"
      t.string :card_id, comment: "カードID"
      t.index :staff_id, unique: true
    end
  end
end
