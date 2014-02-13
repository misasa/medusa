class RemoveAuthorlistFromBibs < ActiveRecord::Migration
  def self.up
    remove_column :bibs, :authorlist, :string
  end
  
  def self.down
    add_column :bibs, :authorlist, :string
  end
end
