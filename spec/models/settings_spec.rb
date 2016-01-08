require 'spec_helper'

describe Settings do

  describe "Inheritance" do
    it { expect(Settings.superclass).to eq Settingslogic }
  end

  describe ".source" do
    it { expect(Settings.source).to eq Rails.root.join("config", "application.yml").to_path }
  end

  describe ".namespece" do
    it { expect(Settings.namespace).to eq Rails.env }
  end

  describe ".barcode_type" do
    let(:data){YAML.load_file(file_yaml)}
    let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
    after do 
      data["defaults"]["barcode"]["type"] = "3D"
      File.open(file_yaml,"w"){|f| f.write data.to_yaml}
      Settings.reload!
    end
    context "yml not nil " do
      before do
          data["defaults"]["barcode"]["type"] = "3D"
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      it {expect(Settings.barcode_type).to eq "3D"}
    end
    context "yml nil " do
      before do
          data["defaults"]["barcode"]["type"] = nil
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      it {expect(Settings.barcode_type).to eq '2D'}
    end
  end

  describe ".barcode_prefix" do
    let(:data){YAML.load_file(file_yaml)}
    let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
    after do 
      data["defaults"]["barcode"]["prefix"] = nil
      File.open(file_yaml,"w"){|f| f.write data.to_yaml}
      Settings.reload!
    end
    context "yml not nil " do
      before do
          data["defaults"]["barcode"]["prefix"] = "aaa"
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      it {expect(Settings.barcode_prefix).to eq "aaa"}
    end
    context "yml nil " do
      before do
          data["defaults"]["barcode"]["prefix"] = nil
          File.open(file_yaml,"w"){|f| f.write data.to_yaml}
          Settings.reload!
      end
      it {expect(Settings.barcode_prefix).to eq ''}
    end
  end

  describe ".specimen_name" do
    subject { Settings.specimen_name }
    let(:path) { Rails.root.join("config", "application.yml").to_path }
    let(:yaml_data) { YAML.load_file(path) }
    before do
      yaml_data["test"]["alias_specimen"] = alias_specimen
      File.open(path, "w") { |f| f.write yaml_data.to_yaml }
      Settings.reload!
    end
    after do
      yaml_data["test"]["alias_specimen"] = "stone"
      File.open(path, "w") { |f| f.write yaml_data.to_yaml }
      Settings.reload!
    end
    context "alias_specimen not nil" do
      let(:alias_specimen) { "Foo" }
      it { expect(subject).to eq alias_specimen }
    end
    context "alias_specimen is nil" do
      let(:alias_specimen) { nil }
      it { expect(subject).to eq "specimen" }
    end
  end

  describe ".sesar_url" do
    subject { Settings.sesar_url(opts) }
    let(:opts){ {:igsn => igsn, :edit => edit_flag } }
    let(:igsn){ "IEDRM0001"}
    let(:edit_flag){ nil }
    it { expect(subject).to be_eql("http://app.geosamples.org/sample/igsn/#{igsn}") }
    context "without igsn" do
      let(:igsn){ nil }
      it { expect(subject).to be_eql("http://app.geosamples.org/views/my_sample_browser.php") } 
    end
    context "with edit flag" do
      let(:edit_flag){ true }
      it { expect(subject).to be_eql("http://app.geosamples.org/samples/edit.php?igsn=#{igsn}") }
    end
  end


end
