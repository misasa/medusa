desc "Set sample_type attribute to physical_forms records."
task set_sample_type: :environment do
  csv = CSV.read(Rails.root.join("db", "csvs", "physical_forms.csv"), headers: true)
  sample_types = csv.each_with_object({}) { |row, hash| hash[row["name"]] = row["sesar_sample_type"] }
  ActiveRecord::Base.transaction do
    PhysicalForm.find_each do |physical_form|
      physical_form.sesar_sample_type ||= sample_types[physical_form.name]
      physical_form.save!
    end
  end
end
