class AddNameToRecordProperties < ActiveRecord::Migration[4.2]
  def up
    change_table :record_properties do |t|
      t.string :name
      t.timestamps
    end
    RecordProperty.find_each do |record_property|
      parent = record_property.datum
      record_property.attributes = {name: parent.try(:name), created_at: parent.created_at, updated_at: parent.updated_at}
      record_property.save(validate: false)
    end
  end

  def down
    change_table :record_properties do |t|
      t.remove :name
      t.remove :created_at
      t.remove :updated_at
    end
  end
end
