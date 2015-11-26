class AddPriorityToBibAuthors < ActiveRecord::Migration
  def change
    add_column :bib_authors, :priority, :integer
  end
end
