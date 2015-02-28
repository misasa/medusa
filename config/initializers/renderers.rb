class Array
	def to_pml(options={})
	    xml = ::Builder::XmlMarkup.new(indent: 2)
	    xml.instruct!
	    xml.acquisitions do
	      each do |obj|
	      	obj = obj.datum if obj.instance_of?(RecordProperty)
	      	if obj.instance_of?(Analysis)
	      		obj.to_pml(xml)
	      	elsif obj.respond_to?(:analysis)
	      		obj.analysis.to_pml(xml)
	      	elsif obj.respond_to?(:analyses)
	      		obj.analyses.each do |analysis|
	      			analysis.to_pml(xml)
	      		end
	      	end
	      end
	    end

	end
end

ActionController::Renderers.add :pml do |object, options|
	self.content_type ||= Mime::PML
	object.respond_to?(:to_pml) ? object.to_pml : object
end