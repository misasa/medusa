namespace :db do
  desc "Renew name and timestamps to record_properties."
  task update_record_properties: :environment do
    RecordProperty.find_each do |record_property|
      parent = record_property.datum
      if parent
        record_property.attributes = {name: parent.try(:name), created_at: parent.created_at, updated_at: parent.updated_at}
        record_property.save(validate: false) if record_property.changed?
      else
        record_property.destroy
      end
    end
  end
end
