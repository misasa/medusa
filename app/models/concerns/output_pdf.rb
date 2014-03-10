module OutputPdf
  extend ActiveSupport::Concern

  included do
    require 'barby/barcode/qr_code'
    require 'barby/outputter/png_outputter'
    QRCODE_DIM = 2
    QRCODE_ENCODING = 'UTF-8'
  end

  def build_card
    resource = self
    ThinReports::Report.create(layout: template_path("card")) do |r|
      r.start_new_page do
        item(:name).value(resource.try(:name))
        item(:global_id).value(resource.global_id)
        item(:qr_code).src(resource.qr_image)
        item(:image).value(resource.primary_attachment_file_path)
      end
    end
  end

  def template_path(type)
    File.join(Rails.root, "app", "assets", "reports", "#{type}_template.tlf")
  end

  def qr_image
    qr_data = Barby::QrCode.new(global_id).to_png(xdim: QRCODE_DIM, ydim: QRCODE_DIM)
    StringIO.new(qr_data).set_encoding(QRCODE_ENCODING)
  end

  def primary_attachment_file_path
    if attachment_files.present?
      path = File.join(Rails.root, "public", attachment_files.first.path)
      File.exist?(path) ? path : nil
    end
  end

  module ClassMethods
    def build_bundle_card(resources)
      report = ThinReports::Report.new(layout: resources.first.template_path("list"))
      divide_by_three(resources).each do |resource_1, resource_2, resource_3|
        report.list.add_row do |row|
          row.item(:name_1).value(resource_1.try(:name))
          row.item(:global_id_1).value(resource_1.global_id)
          row.item(:qr_code_1).src(resource_1.qr_image)
          row.item(:image_1).value(resource_1.primary_attachment_file_path)
          resource_2 ? row.item(:name_2).value(resource_2.try(:name)) : row.item(:name_2).hide
          resource_2 ? row.item(:global_id_2).value(resource_2.global_id) : row.item(:global_id_2).hide
          resource_2 ? row.item(:qr_code_2).value(resource_2.qr_image) : row.item(:qr_code_2).hide
          resource_2 ? row.item(:image_2).value(resource_2.primary_attachment_file_path) : row.item(:image_2).hide
          resource_3 ? row.item(:name_3).value(resource_3.try(:name)) : row.item(:name_3).hide
          resource_3 ? row.item(:global_id_3).value(resource_3.global_id) : row.item(:global_id_3).hide
          resource_3 ? row.item(:qr_code_3).value(resource_3.qr_image) : row.item(:qr_code_3).hide
          resource_3 ? row.item(:image_3).value(resource_3.primary_attachment_file_path) : row.item(:image_3).hide
        end
      end
      report
    end

    private
    def divide_by_three(resources)
      ary = []
      resources.in_groups_of(3) { |group| ary << group }
      ary
    end
  end

end
