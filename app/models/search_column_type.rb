class SearchColumnType
  YAML_PATH = "config/search_column_types.yml"

  attr_reader :datum_type, :column_name, :search_name, :search_form, :create_form, :call_content

  def initialize(datum_type, column_name, attributes)
    begin
      @datum_type = datum_type
      @column_name = column_name
      @search_name = attributes.fetch("search_name")
      @search_form = attributes.fetch("search_form")
      @create_form = {}
      @create_form[:index] = attributes.fetch("create_form").fetch("index")
      @create_form[:bundle_edit] = attributes.fetch("create_form").fetch("bundle_edit")
      @call_content = attributes.fetch("call_content")
    rescue KeyError => e
      raise(e.class, "#{e.message} is not set in \"#{datum_type}: #{column_name}:\" of \"#{YAML_PATH}\"", backtrace = e.backtrace)
    end
  end

  def self.search_column_types
    @@search_column_types ||= YAML.load(File.open(YAML_PATH)).each_with_object({}) do |(datum_type, column_configs), hash|
      hash[datum_type] = column_configs.each_with_object({}) do |(column_name, attributes), hash|
        hash[column_name] = new(datum_type, column_name, attributes)
      end
    end
  end

  def self.val(datum_type, column_name)
    search_column_types[datum_type.to_s][column_name]
  end
end
