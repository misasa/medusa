class RemoveAuthorlistFromBibs < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :bibs, :authorlist, :string
  end
  
  def self.down
    add_column :bibs, :authorlist, :string
  end
end
