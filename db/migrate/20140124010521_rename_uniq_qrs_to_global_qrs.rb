class RenameUniqQrsToGlobalQrs < ActiveRecord::Migration[4.2]
  def change
    rename_table :uniq_qrs, :global_qrs
  end
end
