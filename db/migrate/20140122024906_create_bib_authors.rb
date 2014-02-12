class CreateBibAuthors < ActiveRecord::Migration
  def change
    create_table :bib_authors do |t|
      t.integer :bib_id
      t.integer :author_id
    end
    
    add_index :bib_authors, :bib_id
    add_index :bib_authors, :author_id
  end
end
