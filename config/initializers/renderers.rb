class Array
  def to_pml(options={})

    xml = ::Builder::XmlMarkup.new(indent: 2)
    xml.instruct!
    xml.acquisitions do
      array = []
      each do |obj|
        obj = obj.datum if obj.instance_of?(RecordProperty)
        if obj.instance_of?(Analysis)
          array << obj
#          obj.to_pml(xml)
        elsif obj.instance_of?(Table)
          obj.selected_analyses.each do |analysis|
            array << analysis
#            analysis.to_pml(xml)
          end
        elsif obj.instance_of?(Bib)
          obj.referrings_analyses.each do |analysis|
            array << analysis
          end
        else
#          analyses = []
          array << obj.analysis if obj.respond_to?(:analysis)
          #analyses << obj.analysis if obj.respond_to?(:analysis)
          if obj.respond_to?(:analyses)
            #analyses.concat(obj.analyses)
            array.concat(obj.analyses)
          end

          if obj.respond_to?(:spots)
            obj.spots.each do |spot|
#              analyses.delete(spot.target) if spot.target && spot.target.instance_of?(Analysis)
#              analyses << spot
              array.delete(spot.target) if spot.target && spot.target.instance_of?(Analysis)
              array << spot
            end
          end
#          analyses = analyses.uniq.compact
#          analyses.each do |analysis|
#            analysis.to_pml(xml)
#          end
        end # if
        array = array.uniq.compact
        array.each do |el|
          el.to_pml(xml)
        end
      end # each
    end # xml.acquisitions
  end # def
end # class

ActionController::Renderers.add :pml do |object, options|
	self.content_type ||= Mime::PML
	object.respond_to?(:to_pml) ? object.to_pml : object
end
