module OutputCsv
  extend ActiveSupport::Concern

  included do
    LABEL_HEADER = ["Id","Name"]
  end

  def build_label
    CSV.generate do |csv|
      csv << LABEL_HEADER
      csv << ["#{global_id}", "#{name}"]
    end
  end

  module ClassMethods
    def build_bundle_label(resources)
      CSV.generate do |csv|
        csv << LABEL_HEADER
        resources.each do |resource|
          csv << ["#{resource.global_id}", "#{resource.name}"]
        end
      end
    end
  end

end
