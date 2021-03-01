class ChangeDatatypeSizeOfStones < ActiveRecord::Migration[4.2]
  def change
    change_column :stones, :size, :string
  end
end
