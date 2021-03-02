class AddNoteToPaths < ActiveRecord::Migration[4.2]
  def change
    add_column :paths, :note, :text
  end
end
