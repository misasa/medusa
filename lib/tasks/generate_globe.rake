namespace :db do
  desc "Generate globe record to surfaces."
  task generate_globe: :environment do
    Surface.find_or_create_by!(name: 'globe', globe: true)
  end
end
