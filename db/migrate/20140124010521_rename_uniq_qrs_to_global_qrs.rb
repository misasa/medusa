class RenameUniqQrsToGlobalQrs < ActiveRecord::Migration
  def change
    rename_table :uniq_qrs, :global_qrs
  end
end
