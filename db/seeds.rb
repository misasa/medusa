admin = User.create(username: 'admin', administrator: true, email: Settings.admin.email, password: Settings.admin.initial_password, password_confirmation: Settings.admin.initial_password)
admin_group = Group.create(name: 'admin')
admin_group.users << admin
BoxType.create(name: 'building')
BoxType.create(name: 'floor')
BoxType.create(name: 'room')
BoxType.create(name: 'shelf')
container = BoxType.create(name: 'container')
BoxType.create(name: 'mount')
admin_box = Box.create(name: 'admin', box_type_id: container.id)
admin_box.user = admin
admin_box.group = admin_group
admin.box_id = admin_box.id
admin.save 
Rake::Task["search_column:create"].invoke
materials = YAML.load(File.read("#{Rails.root}/config/material_classification.yml"))["material"]
materials.each do |material|
  PhysicalForm.create(name: material)
end
Rake::Task["sesar:classification:create"].invoke
Rake::Task["sesar:sample_type:create"].invoke
Rake::Task["earthchem:parameter:create"].invoke
Rake::Task["earthchem:technique:create"].invoke
Rake::Task["earthchem:unit:create"].invoke
ActiveRecord::Base.transaction do
  Device.destroy_all
  Device.create(name: 'JEOL JXA-8800')
  Device.create(name: 'Cameca ims-1280')
  Device.create(name: 'Thermo electron NEPTUNE')
end
#Rake::Task[:create_work_dir].invoke

#csv_dir = Rails.root.join("db", "csvs")
#array_csv = Pathname.glob(csv_dir.join("*.csv"))
#work_dir = Pathname.new("/tmp/medusa_csv_files")
#FileUtils.cp(array_csv, work_dir)

#Rake::Task[:csv_data_moving].invoke

#FileUtils.rm_r(work_dir)