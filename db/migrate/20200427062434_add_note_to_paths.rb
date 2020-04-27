class AddNoteToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :note, :text
  end
end
