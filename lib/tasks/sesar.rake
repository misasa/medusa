def load_classification
  classifications = YAML.load(File.read("#{Rails.root}/config/material_classification.yml"))["classification"]
  h = Hash.new
  classifications.each do |key, array|
    tokenss = []
    array.each do |line|
      tokenss.push(line.split('>'))
    end
    h[key] = tokenss
  end
  h
end
def rread(h, tokens)
  top = tokens.shift
  h[top] = {} unless h.has_key?(top)

  if tokens.size > 1
    rread(h[top], tokens)
  elsif tokens.size == 1
    h[top][tokens[0]] = {}
  end
  return h
end

def rcreate(h, parent_id, material)
  h.each do |key, val|
    obj = Classification.create(name: key, parent_id: parent_id, sesar_material: material)
    if val.size > 0
      rcreate(h[key], obj.id, material) 
    end
  end
end
namespace :sesar do
  namespace :sample_type do
    desc "Create sample_type."
    task create: :environment do
      sample_types = YAML.load(File.read("#{Rails.root}/config/sample_type.yml"))["sample_type"]
      ActiveRecord::Base.transaction do
        PhysicalForm.destroy_all
        sample_types.each do |sample_type|
          PhysicalForm.create(name: sample_type)
        end
      end
    end
  end
  namespace :classification do
    desc "Create classification."
    task create: :environment do
      h_tokenss = load_classification
      ActiveRecord::Base.transaction do
        Classification.destroy_all
        h = Hash.new
        h_tokenss.each do |material, tokenss|
          #next unless material == 'Rock'
          tokenss.each do |tokens|
            h = rread(h, tokens)
          end
          rcreate(h, nil, material)
        end
      end
    end
  end  
end