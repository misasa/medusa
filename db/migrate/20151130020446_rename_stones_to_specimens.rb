class RenameStonesToSpecimens < ActiveRecord::Migration[4.2]
  def change
    rename_table :stones, :specimens
  end
end
