namespace :map do
  namespace :surface do
    desc "List surfaces"
    task :list => [:environment] do |t|
      surfaces = Surface.order(updated_at: :desc)
      surfaces.each do |surface|
        puts "#{surface.id} #{surface.name}"
      end
    end

    desc "Create tiles"
    task :create => [:environment] do |t|
      if ENV['surface_id']
        surfaces = [Surface.find(ENV['surface_id'])]
      else
        surfaces = Surface.all
      end
      surfaces.each do |surface|
        map = Map.new(surface)
        map.generate_tiles
      end
    end
  end
end