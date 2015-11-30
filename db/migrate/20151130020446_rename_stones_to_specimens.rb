class RenameStonesToSpecimens < ActiveRecord::Migration
  def change
    rename_table :stones, :specimens
  end
end
