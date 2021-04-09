admin = User.create(username: 'admin', administrator: true, email: Settings.admin.email, password: Settings.admin.initial_password, password_confirmation: Settings.admin.initial_password)
admin_group = Group.create(name: 'admin')
admin_group.users << admin
admin_box = Box.create(name: 'admin')
admin_box.user = admin
admin_box.group = admin_group
admin.box_id = admin_box.id
admin.save 
Rake::Task["search_column:create"].invoke
#Rake::Task[:create_work_dir].invoke

#csv_dir = Rails.root.join("db", "csvs")
#array_csv = Pathname.glob(csv_dir.join("*.csv"))
#work_dir = Pathname.new("/tmp/medusa_csv_files")
#FileUtils.cp(array_csv, work_dir)

#Rake::Task[:csv_data_moving].invoke

#FileUtils.rm_r(work_dir)