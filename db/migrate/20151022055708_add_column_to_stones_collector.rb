class AddColumnToStonesCollector < ActiveRecord::Migration
  def change
    change_table :stones do |t|
      t.string :collector
      t.string :collector_detail
    end
  end
end
