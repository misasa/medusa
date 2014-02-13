class CreateTechniques < ActiveRecord::Migration
  def change
    create_table :techniques do |t|
      t.string  :name
      
      t.timestamps
    end
  end
end
