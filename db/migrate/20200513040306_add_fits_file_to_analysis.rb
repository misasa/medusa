class AddFitsFileToAnalysis < ActiveRecord::Migration
  def change
    add_column :analyses, :fits_file_id, :integer
  end
end
