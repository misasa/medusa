module OutputReport
  extend ActiveSupport::Concern

  included do
    require 'barby/barcode/qr_code'
    require 'barby/outputter/png_outputter'
    QRCODE_DIM = 2
  end

  def build_report
    resource = self
    ThinReports::Report.create(layout: card_template) do |r|
      r.start_new_page do
        item(:name).value(resource.try(:name))
        item(:global_id).value(resource.global_id)
        item(:qr_code).src(resource.qr_image)
        if resource.attachment_files.present?
          path = File.join(Rails.root, "public", resource.attachment_files.first.path)
          item(:image).value(File.exist?(path) ? path : nil)
        else
          item(:image).hide
        end
      end
    end
  end

  def card_template
    File.join(Rails.root, "app", "assets", "reports", "card_template.tlf")
  end

  def qr_image
    barby = Barby::QrCode.new(global_id).to_png(xdim: QRCODE_DIM, ydim: QRCODE_DIM)
    StringIO.new(barby).set_encoding('UTF-8')
  end

end
