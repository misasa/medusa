# -*- coding: utf-8 -*-
require 'spec_helper'

describe SurfaceLayer do
    describe "validates" do
        describe "name" do
          let(:obj) { FactoryGirl.build(:surface_layer, name: name) }
          context "is presence" do
            let(:name) { "layer-1" }
            it { expect(obj).to be_valid }
          end
          context "is blank" do
            let(:name) { "" }
            it { expect(obj).not_to be_valid }
          end
          describe "length" do
            context "is 255 characters" do
              let(:name) { "a" * 255 }
              it { expect(obj).to be_valid }
            end
            context "is 256 characters" do
              let(:name) { "a" * 256 }
              it { expect(obj).not_to be_valid }
            end
          end
        end    
    end

    describe "tile_dir" do
        let(:surface) { FactoryGirl.create(:surface) }
        let(:obj) { FactoryGirl.create(:surface_layer, name: "layer-1", :surface_id => surface.id)}      
        subject { obj.tile_dir }
        it { expect(subject).not_to be_nil }
    end
end