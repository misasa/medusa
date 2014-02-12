class AddUsernameToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :username
    end
    User.all.each { |user| user.update_attributes(username: user.email.split("@").first) }
    change_table :users do |t|
      t.change :username, :string, null: false
      t.index :username, unique: true
    end
  end

  def down
    change_table :users do |t|
      t.remove :username
      t.remove_index :username
    end
  end
end
