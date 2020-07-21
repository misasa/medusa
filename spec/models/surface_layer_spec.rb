# -*- coding: utf-8 -*-
require 'spec_helper'

describe SurfaceLayer do
    describe "validates" do
        describe "max_zoom_level" do
          let(:obj) { FactoryGirl.build(:surface_layer, name: name, max_zoom_level: max_zoom_level) }
          let(:name) { "layer-1" }
          context "is nil" do
            let(:max_zoom_level) { nil }
            it { expect(obj).to be_valid }
          end
          context "is less than 0" do
            let(:max_zoom_level) { -1 }
            it { expect(obj).not_to be_valid }
          end

          context "is 0" do
            let(:max_zoom_level) { 0 }
            it { expect(obj).to be_valid }
          end

          context "is 14" do
            let(:max_zoom_level) { 14 }
            it { expect(obj).to be_valid }
          end

          context "is greater than 14" do
            let(:max_zoom_level) { 15 }
            it { expect(obj).not_to be_valid }
          end

        end
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

    describe "original_zoom_level" do
      let(:surface) { FactoryGirl.create(:surface) }
      let(:obj) { FactoryGirl.create(:surface_layer, name: "layer-1", :surface_id => surface.id)}      
      subject { obj.original_zoom_level }
      context "without surface_images" do
        it { expect(subject).to be_nil }
      end
      context "with a surface_image" do
        before do
          image_mock = double('SurfaceImage')
          image_mock.should_receive(:original_zoom_level).and_return(2)
          allow(obj).to receive(:surface_images).and_return([image_mock])
        end
        it { expect(subject).to be_eql(2) }
      end

      context "with surface_images" do
        before do
          image_mock_1 = double('SurfaceImage')
          image_mock_1.should_receive(:original_zoom_level).and_return(2)
          image_mock_2 = double('SurfaceImage')
          image_mock_2.should_receive(:original_zoom_level).and_return(13)
          image_mock_3 = double('SurfaceImage')
          image_mock_3.should_receive(:original_zoom_level).and_return(4)
          allow(obj).to receive(:surface_images).and_return([image_mock_1, image_mock_2, image_mock_3])
        end
        it { expect(subject).to be_eql(13) }
      end
  
    end
end