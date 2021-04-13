namespace :earthchem do
  namespace :parameter do
    desc "Create parameter."
    task create: :environment do
      ActiveRecord::Base.transaction do
        MeasurementItem.destroy_all
        File.read("#{Rails.root}/config/earthchem_parameter.tsv").split("\n").each do |line|
          parameter, description = line.split("\t")
          MeasurementItem.create(nickname: parameter, description: description)
        end
      end
    end
  end
  namespace :technique do
    desc "Create technique."
    task create: :environment do
      ActiveRecord::Base.transaction do
        Technique.destroy_all
        File.read("#{Rails.root}/config/earthchem_technique.tsv").split("\n").each do |line|
          name, description = line.split("\t")
          Technique.create(name: name)
        end
      end
    end
  end
  namespace :unit do
    desc "Create unit."
    task create: :environment do
      #ActiveRecord::Base.transaction do
        Unit.destroy_all
        Unit.create(name: 'micro_gram_per_gram', conversion: 1000000, html: '&micro;g/g', text: 'ug/g')
        Unit.create(name: 'pico_gram_per_gram', conversion: 1000000000000, html: 'pg/g', text: 'pg/g')
        Unit.create(name: 'nano_gram_per_gram', conversion: 1000000000, html: 'ng/g', text: 'ng/g')
        Unit.create(name: 'centi_gram_per_gram', conversion: 100, html: 'cg/g', text: 'cg/g')
        Unit.create(name: 'femt_gram_per_gram', conversion: 1e+15, html: 'fg/g', text: 'fg/g')
        Unit.create(name: 'parts_per_myriad', conversion: 10000, html: '&#8241;', text: 'permyriad')
        Unit.create(name: 'parts_per_mille', conversion: 1000, html: '&#8240;', text: 'permil')
        Unit.create(name: 'parts_per_cent', conversion: 100, html: '&#37;', text: '%')
        Unit.create(name: 'parts_per_milli', conversion: 1000000, html: 'ppm', text: 'ppm')
        Unit.create(name: 'parts_per_billi', conversion: 1000000000, html: 'ppb', text: 'ppb')
      #end
    end
  end
end