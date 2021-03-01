class AddPriorityToBibAuthors < ActiveRecord::Migration[4.2]
  def change
    add_column :bib_authors, :priority, :integer
  end
end
