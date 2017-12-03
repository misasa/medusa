namespace :db do
  desc "Generate globe record to surfaces."
  task generate_globe: :environment do
    at = Time.zone.local(9999, 12, 31, 23, 59, 59)
    Surface.find_or_create_by!(name: 'globe', globe: true, created_at: at, updated_at: at)
  end
end
