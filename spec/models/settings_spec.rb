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
    it {expect(Settings.barcode_type).to eq Settings.barcode['type']||'2D'}
  end

  describe ".barcode_prefix" do
    it {expect(Settings.barcode_prefix).to eq Settings.barcode['prefix']||''}
  end
end
