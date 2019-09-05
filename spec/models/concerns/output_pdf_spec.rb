require "spec_helper"

class OutputPdfSpec < ActiveRecord::Base
  include OutputPdf
end

class OutputPdfSpecMigration < ActiveRecord::Migration
  def self.up
    create_table :output_pdf_specs do |t|
      t.string :name
      t.string :global_id
    end
  end
  def self.down
    drop_table :output_pdf_specs
  end
end

describe OutputPdf do
  let(:klass) { OutputPdfSpec }
  let(:migration) { OutputPdfSpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }

  describe "constants" do
    describe "QRCODE_DIM" do
      subject { klass::QRCODE_DIM }
      it { expect(subject).to eq 2 }
    end
  end

  describe "build_card" do
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    before { allow(obj).to receive(:set_card_data) }
    after { obj.build_card }
    it { expect(ThinReports::Report).to receive(:new).and_call_original }
    it { expect(obj).to receive(:report_template).with("card").and_call_original }
    it { expect(obj).to receive(:set_card_data) }
    it { expect(obj.build_card.class).to eq ThinReports::Report::Base }
  end

  describe "report_template" do
    subject { obj.report_template(type) }
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    let(:type) { "bar" }
    it { expect(subject).to eq "#{Rails.root}/app/assets/reports/bar_template.tlf" }
  end

  describe "set_card_data" do
    after { obj.set_card_data(page) }
    let(:obj) { klass.create(name: name, global_id: global_id) }
    let(:name) { "foo" }
    let(:global_id) { "1234" }
    let(:page) { double(:page) }
    let(:item_name) { double(:item_name) }
    let(:item_global_id) { double(:item_global_id) }
    let(:item_qr_code) { double(:item_qr_code) }
    let(:item_image) { double(:item_image) }
    let(:qr_image) { double(:qr_image) }
    let(:primary_attachment_file_path) { double(:primary_attachment_file_path) }
    before do
      allow(obj).to receive(:qr_image).and_return(qr_image)
      allow(obj).to receive(:primary_attachment_file_path).and_return(primary_attachment_file_path)
      allow(page).to receive(:item).with(:name).and_return(item_name)
      allow(page).to receive(:item).with(:global_id).and_return(item_global_id)
      allow(page).to receive(:item).with(:qr_code).and_return(item_qr_code)
      allow(page).to receive(:item).with(:image).and_return(item_image)
      allow(item_name).to receive(:value).with(name)
      allow(item_global_id).to receive(:value).with(global_id)
      allow(item_qr_code).to receive(:src).with(qr_image)
      allow(item_image).to receive(:value).with(primary_attachment_file_path)
    end
    it { expect(page).to receive(:item).with(:name) }
    it { expect(item_name).to receive(:value).with(name) }
    it { expect(page).to receive(:item).with(:global_id) }
    it { expect(item_global_id).to receive(:value).with(global_id) }
    it { expect(page).to receive(:item).with(:qr_code) }
    it { expect(item_qr_code).to receive(:src).with(qr_image) }
    it { expect(page).to receive(:item).with(:image) }
    it { expect(item_image).to receive(:value).with(primary_attachment_file_path) }
  end

  describe "qr_image" do
    after { obj.qr_image }
    before { allow_any_instance_of(StringIO).to receive(:set_encoding).and_return(string_io) }
    let(:obj) { klass.create(name: "foo", global_id: global_id) }
    let(:global_id) { "1234" }
    let(:string_io) { double(:string_io) }
    let(:dim) { klass::QRCODE_DIM }
    it { expect(Barby::QrCode).to receive(:new).with(global_id).and_call_original }
    it { expect_any_instance_of(Barby::QrCode).to receive(:to_png).with({xdim: dim, ydim: dim}).and_call_original }
    it { expect_any_instance_of(StringIO).to receive(:set_encoding).with("UTF-8") }
    it { expect(obj.qr_image).to eq string_io }
  end

  describe "primary_attachment_file_path" do
    subject { obj.primary_attachment_file_path }
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    before { allow(obj).to receive(:attachment_files).and_return(attachment_files) }
    context "attachment_files is blank" do
      let(:attachment_files) { [] }
      it { expect(subject).to be_nil }
    end
    context "attachment_files is present" do
      let(:attachment_files) { [file] }
      let(:file) { FactoryGirl.create(:attachment_file) }
      context "file.data.path is exist" do
        before { allow(File).to receive(:exist?).and_return(true) }
        it { expect(subject).to eq file.data.path }
      end
      context "file.data.path isn't exist" do
        before { allow(File).to receive(:exist?).and_return(false) }
        it { expect(subject).to be_nil }
      end
    end
  end

  describe "build_a_four" do
    after { klass.build_a_four(resources) }
    let(:resources) { [obj] }
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    before do
      allow(obj).to receive(:primary_attachment_file_path)
    end
    it { expect(ThinReports::Report).to receive(:new).and_call_original }
    it { expect(obj).to receive(:report_template).with("bundle").and_call_original }
    it { expect(klass).to receive(:divide_by_three).with(resources).and_call_original }
    it { expect(klass).to receive(:set_bundle_data).exactly(3).times }
    it { expect(klass.build_a_four(resources).class).to eq ThinReports::Report::Base }
  end

  describe "build_cards" do
    after { klass.build_cards(resources) }
    let(:resources) { [obj] }
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    before { allow(obj).to receive(:set_card_data) }
    it { expect(ThinReports::Report).to receive(:new).and_call_original }
    it { expect(obj).to receive(:report_template).with("card").and_call_original }
    it { expect(obj).to receive(:set_card_data) }
    it { expect(klass.build_cards(resources).class).to eq ThinReports::Report::Base }
  end

  describe "divide_by_three" do
    subject { klass.send(:divide_by_three, resources) }
    context "resources is blank" do
      let(:resources) { [] }
      it { expect(subject).to eq [] }
    end
    context "resources has 1 object" do
      let(:resources) { [1] }
      it { expect(subject).to eq [[1, nil, nil]] }
    end
    context "resources has 2 objects" do
      let(:resources) { [1, 2] }
      it { expect(subject).to eq [[1, 2, nil]] }
    end
    context "resources has 3 objects" do
      let(:resources) { [1, 2, 3] }
      it { expect(subject).to eq [[1, 2, 3]] }
    end
    context "resources has 4 objects" do
      let(:resources) { [1, 2, 3, 4] }
      it { expect(subject).to eq [[1, 2, 3], [4, nil, nil]] }
    end
  end

  describe "set_bundle_data" do
    after { klass.send(:set_bundle_data, row, num, resource) }
    let(:row) { double(:row) }
    let(:num) { 1 }
    let(:row_item) { double(:item) }
    context "resource is nil" do
      let(:resource) { nil }
      before do
        allow(row).to receive(:item).and_return(row_item)
        allow(row_item).to receive(:hide)
      end
      it { expect(row).to receive(:item).with(:name_1) }
      it { expect(row).to receive(:item).with(:global_id_1) }
      it { expect(row).to receive(:item).with(:qr_code_1) }
      it { expect(row).to receive(:item).with(:image_1) }
      it { expect(row_item).to receive(:hide).exactly(4).times }
    end
    context "resource is present" do
      let(:resource) { klass.create(name: "foo", global_id: "1234") }
      let(:qr_image) { double(:qr_image) }
      let(:primary_attachment_file_path) { double(:path) }
      before do
        allow(resource).to receive(:qr_image).and_return(qr_image)
        allow(resource).to receive(:primary_attachment_file_path).and_return(primary_attachment_file_path)
        allow(row).to receive(:item).and_return(row_item)
        allow(row_item).to receive(:value).with(resource.name)
        allow(row_item).to receive(:value).with(resource.global_id)
        allow(row_item).to receive(:src).with(resource.qr_image)
        allow(row_item).to receive(:value).with(resource.primary_attachment_file_path)
      end
      it { expect(row).to receive(:item).with(:name_1) }
      it { expect(row_item).to receive(:value).with(resource.name) }
      it { expect(row).to receive(:item).with(:global_id_1) }
      it { expect(row_item).to receive(:value).with(resource.global_id) }
      it { expect(row).to receive(:item).with(:qr_code_1) }
      it { expect(row_item).to receive(:src).with(qr_image) }
      it { expect(row).to receive(:item).with(:image_1) }
      it { expect(row_item).to receive(:value).with(primary_attachment_file_path) }
    end
  end

end
