def fmt_long(obj)
  items = ["<#{obj.class.human_name.downcase}: #{obj.uniq_id}>"]
  items << "<link: stone=#{obj.stone_count} box=#{obj.box_count} analysis=#{obj.analysis_count} file=#{obj.file_count} bib=#{obj.bib_count} locality=#{obj.locality_count} point=#{obj.point_count}>"
  items << "<last-modifed: #{obj.updated_at}>"
  items << "<created: #{obj.created_at}>"
  items.join(" ")
end

namespace :record do
	namespace :dump do
		desc "Dump records in latex-mode"
		task :list => [:environment] do |t|
			boxes = Box.order(updated_at: :desc)
			stones = Stone.order(updated_at: :desc)
			bibs = Bib.order(updated_at: :desc)

			physicalitems = boxes
			physicalitems.concat(stones)

		  	output_path = ENV['output_path'] || "tmp/auto-stone-list"
			#STDERR.puts "writing |#{output_path}|..."
		  	output = File.open(output_path,"w")
			physicalitems.each do |obj|
				output.puts "#{obj.latex_mode(:box)}"
				#puts "#{obj.full_name(:box)} #{fmt_long(obj)}" 
			end

			stones.each do |obj|
				#puts "#{obj.full_name(:blood).gsub(/\//,"\\")} #{fmt_long(obj)}"
				output.puts "#{obj.latex_mode(:blood).gsub(/\//,"\\")}"
			end

			bibs.each do |obj|
				output.puts "#{obj.latex_mode(:blood)}"
			end
			output.close
		end

		desc "Dump records in bib-mode"
		task :bib => [:environment] do |t|
			items = Box.order(updated_at: :desc)
			items.concat(Stone.order(updated_at: :desc))
			items.concat(Bib.order(updated_at: :desc))
		  	output_path = ENV['output_path'] || "tmp/ref_dream.bib"
			#STDERR.puts "writing |#{output_path}|..."
		  	output = File.open(output_path,"w")

			items.each do |obj|
				output.puts "#{obj.to_bibtex}"
			end
			output.close

		end
	end
end