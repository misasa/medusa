desc "Build paths records from current specimens and boxes."
task build_paths: :environment do
  admin = User.find_by(username: "admin")
  Box.find_each do |box|
    ancestors = box.ancestors
    path = Path.new
    path.datum = box
    path.ids = ancestors.map(&:id)
    path.brought_in_at = Time.now
    path.brought_in_by_id = admin.id
    path.save
  end
  Specimen.find_each do |specimen|
    box = specimen.box
    ancestors = box.try!(:ancestors) || Box.none
    path = Path.new
    path.datum = specimen
    path.ids = ancestors.map(&:id)
    path.ids << box.id if box
    path.brought_in_at = Time.now
    path.brought_in_by_id = admin.id
    path.save
  end
end
