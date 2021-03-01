class AddAccessTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.string :staff_id, comment: "職員ID"
      t.string :card_id, comment: "カードID"
      t.index :staff_id, unique: true
    end
  end
end
