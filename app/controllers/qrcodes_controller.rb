require "barby/barcode/qr_code"
require "barby/outputter/png_outputter"

class QrcodesController < ApplicationController
  def show
    qrcode = Barby::QrCode.new(params[:id], size: 4).to_png(xdim: 4)
    send_data(qrcode, filename: "#{params[:id]}.png", type: :png)
  end
end
