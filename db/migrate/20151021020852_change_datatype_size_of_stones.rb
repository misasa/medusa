class ChangeDatatypeSizeOfStones < ActiveRecord::Migration
  def change
    change_column :stones, :size, :string
  end
end
