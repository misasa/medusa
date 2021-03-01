class AddConversionAndHtmlAndTextToUnits < ActiveRecord::Migration[4.2]
  def change
    Unit.destroy_all
    change_table :units do |t|
      t.integer :conversion, null: false
      t.string :html, limit: 10, null: false
      t.string :text, limit: 10, null: false
    end
  end
end
