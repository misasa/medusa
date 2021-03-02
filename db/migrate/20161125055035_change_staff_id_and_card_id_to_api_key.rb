class ChangeStaffIdAndCardIdToApiKey < ActiveRecord::Migration[4.2]
  def up
    change_table :users do |t|
      t.string :api_key, comment: "APIキー"
      t.index :api_key, unique: true
    end
    ActiveRecord::Base.connection.execute("UPDATE users SET api_key = staff_id || card_id;")
    change_table :users do |t|
      t.remove_index :staff_id
      t.remove :staff_id, :card_id
    end
  end

  def down
    change_table :users do |t|
      t.string :staff_id, comment: "職員ID"
      t.string :card_id, comment: "カードID"
      t.index :staff_id, unique: true
      t.remove_index :api_key
      t.remove :api_key
    end
  end
end
