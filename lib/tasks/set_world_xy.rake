desc "Set world_x and world_y attribute to spots records."
task set_world_xy: :environment do
  Spot.find_each(&:save)
end
