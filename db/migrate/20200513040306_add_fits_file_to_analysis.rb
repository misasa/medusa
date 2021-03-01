class AddFitsFileToAnalysis < ActiveRecord::Migration[4.2]
  def change
    add_column :analyses, :fits_file_id, :integer
  end
end
