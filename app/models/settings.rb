class Settings < Settingslogic
  source Rails.root.join("config", "application.yml").to_path
  namespace Rails.env

  def self.barcode_type
    self.barcode['type'] || '2D'
  end

  def self.barcode_prefix
    self.barcode['prefix'] || ''
  end

  def self.specimen_name
    if has_key?("alias_specimen") && alias_specimen.present?
      alias_specimen
    else
      "specimen"
    end
  end

end
