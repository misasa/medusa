class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.integer :bib_id
      t.integer :measurement_category_id
      t.text    :description
      t.boolean :with_average
      t.boolean :with_place

      t.timestamps
    end

    add_index :tables, :bib_id
    add_index :tables, :measurement_category_id
  end
end
