class AddCollectedEndAtToSpecimens < ActiveRecord::Migration[4.2]
  def change
    add_column :specimens, :collected_end_at, :datetime, comment: "採取終了日時"
  end
end
