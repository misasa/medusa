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

end
