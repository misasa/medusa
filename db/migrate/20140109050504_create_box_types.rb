class CreateBoxTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :box_types do |t|
      t.string :name
      t.text   :description
    end
  end
end
