require "spec_helper"

describe Spot do
  let(:user){FactoryBot.create(:user)}
  before{User.current = user}

  describe "validates" do
    describe "spot_x" do
      let(:obj) { FactoryBot.build(:spot, spot_x: spot_x) }
      context "is presence" do
        let(:spot_x) { "0" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:spot_x) { "" }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "spot_y" do
      let(:obj) { FactoryBot.build(:spot, spot_y: spot_y) }
      context "is presence" do
        let(:spot_y) { "0" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:spot_y) { "" }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe ".generate_name" do
    subject{ spot.name }
    before{spot}
    context "name is not blank" do
      let(:spot){FactoryBot.create(:spot,name: "aaaa")}
      it {expect(subject).to eq "aaaa"}
    end
    context "targe_uid is blank" do
      let(:spot){FactoryBot.create(:spot,name: nil,target_uid: nil)}
      it {expect(subject).to eq "untitled spot 1"}
    end
    context "target_uid is error global_id" do
      let(:spot){FactoryBot.create(:spot,name: nil,target_uid: "aaa")}
      it {expect(subject).to eq "aaa"}
    end
    context "target_uid is no datum  global_id" do
      let(:bib){FactoryBot.create(:bib,name: "test bib")}
      let(:record_property){bib.record_property}
      let(:spot){FactoryBot.build(:spot,name: nil,target_uid: record_property.global_id)}
      before do
        bib.destroy
        spot.save
      end
      it {expect(subject).to eq record_property.global_id}
    end
    context "target_uid is OK global_id" do
      let(:bib){FactoryBot.create(:bib,name: "test bib")}
      let(:spot){FactoryBot.create(:spot,name: nil,target_uid: bib.record_property.global_id)}
      it {expect(subject).to eq "spot of " + bib.name}
    end
  end

  describe ".genarate_stroke_width" do
    subject{ spot.stroke_width }
    context "stroke_width is not blank" do
      let(:spot){FactoryBot.create(:spot,stroke_width: 9)}
      it {expect(subject).to eq 9}
    end
    context "stroke_width is not blank" do
      let(:spot){FactoryBot.build(:spot,stroke_width: nil)}
      before do
        spot.attachment_file.original_geometry = "123x234"
        spot.save
      end
      it {expect(subject).to eq 1.17}
    end
  end

  describe ".to_svg" do
    subject{ spot.to_svg }
    context "stroke_width is not blank" do
      let(:spot){FactoryBot.create(:spot,stroke_width: 9)}
      it {expect(subject).to match(/<circle/)}
    end
  end

  describe "radius_in_um" do
    subject { spot.radius_in_um }
    context "with calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]")}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).not_to be_nil}
    end

    context "when save radius_in_um with calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]")}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      before do
        spot.radius_in_um = 100
        spot.save
      end
      it {expect(subject).not_to be_nil}
      after do
        p spot
      end
    end

    context "without calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).to be_nil}
    end    

    context "when save radius_in_um without calibrated image", :current => true do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      before do
        spot.radius_in_um = 10
        spot.save
      end
      it {expect(subject).to be_eql(10.0)}
      it {expect(spot.radius_in_percent).to be_nil}
    end    

  end

  describe ".spot_world_xy" do
    subject{ spot.spot_world_xy }
    context "with calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]")}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      before do
      end
      it {expect(subject).not_to be_nil}
      it {expect(subject[0]).not_to be_nil}
      it {expect(subject[1]).not_to be_nil}
      after do
        #p spot
      end
    end

    context "without calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "")}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).not_to be_nil}
      it {expect(subject[0]).not_to be_nil}
      it {expect(subject[1]).not_to be_nil}
    end

    context "with nil affine_matrix" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).to be_nil}
    end

  end


  describe ".radius_um_from_percent" do
    subject{ spot.radius_um_from_percent }
    context "with calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]")}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).not_to be_nil}
    end

    context "without calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).to be_nil}
    end

    context "with nil affine_matrix" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).to be_nil}
    end
  end

  describe ".radius_percent_from_um" do
    subject{ spot.radius_percent_from_um }
    context "with calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]")}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id, radius_in_um: 10.0)}
      it {expect(subject).not_to be_nil}
    end

    context "without calibrated image" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).to be_nil}
    end

    context "with nil affine_matrix" do
      let(:image){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix => nil)}
      let(:spot){FactoryBot.create(:spot, attachment_file_id: image.id)}
      it {expect(subject).to be_nil}
    end
  end

  # describe "#spot_x_from_center" do
  #   subject{obj.spot_x_from_center}
  #   let(:obj){FactoryBot.create(:spot)}
  #   it {expect(subject).to eq -49.0}
  # end
  #
  # describe "#spot_y_from_center" do
  #   subject{obj.spot_y_from_center}
  #   let(:obj){FactoryBot.create(:spot)}
  #   it {expect(subject).to eq 49.0}
  # end

  describe "#ref_image_x" do
    subject { spot.ref_image_x }
    let(:spot) { FactoryBot.build(:spot, spot_x: spot_x, attachment_file: attachment_file) }
    let(:spot_x) { 10.0 }
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before do
      allow(attachment_file).to receive(:length).and_return(length)
    end
    context "length is nil" do
      let(:length) { nil }
      it { expect(subject).to be_nil }
    end
    context "length is present" do
      let(:length) { 100 }
      it { expect(subject).to eq (spot_x / length * 100) }
    end
  end

  describe "#ref_image_y" do
    subject { spot.ref_image_y }
    let(:spot) { FactoryBot.build(:spot, spot_y: spot_y, attachment_file: attachment_file) }
    let(:spot_y) { 20.0 }
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before do
      allow(attachment_file).to receive(:length).and_return(length)
    end
    context "length is nil" do
      let(:length) { nil }
      it { expect(subject).to be_nil }
    end
    context "length is present" do
      let(:length) { 100 }
      it { expect(subject).to eq (spot_y / length * 100) }
    end
  end

  describe "#to_pmlame" do
    subject { spot.to_pmlame }
    let(:spot) { FactoryBot.build(:spot, attachment_file: attachment_file, target_uid: analysis.global_id) }
    let(:attachment_file) { FactoryBot.create(:attachment_file, data_content_type: data_content_type, data_file_name: data_file_name) }
    let(:world_x) {}
    let(:world_y) { 60 }
    let(:analysis) { FactoryBot.create(:analysis, specimen_id: specimen.id) }
    let(:specimen) {FactoryBot.create(:specimen, place_id: nil)}
    before do
      allow(spot).to receive(:global_id).and_return('201807181659-9876')
      allow(spot).to receive(:spot_x_from_center).and_return(10)
      allow(spot).to receive(:spot_y_from_center).and_return(20)
      allow(spot).to receive(:world_x).and_return(world_x)
      allow(spot).to receive(:world_y).and_return(world_y)
      #allow(spot).to receive(:get_analysis).and_return(analysis)
    end
    context "when the type of the data_content_type is text/plain," do
      let(:data_content_type) { "text/plain" }
      let(:data_file_name) { "file_name_1.txt" }
      it "return nil" do
        expect(subject).to be_nil
      end
    end
    context "when the type of the data_content_type is application/pdf," do
      let(:data_content_type) { "application/pdf" }
      let(:data_file_name) { "file_name_1.pdf" }
      it "return nil" do
        expect(subject).to be_nil
      end
    end
    context "when the type of the data_content_type is image/jpeg," do
      let(:data_content_type) { "image/jpeg" }
      let(:data_file_name) { "file_name_1.jpg" }
      it "return spot data" do
        result = {
          element: "#{analysis.name} <analysis #{analysis.global_id}>",
          analysis_id: analysis.global_id,
          image_id: attachment_file.global_id,
          image_path: attachment_file.data.url,
          lat: nil,
          lng: nil,
          sample_id: analysis.specimen.global_id,
          surface_id: nil,
          x_image: 10,
          y_image: 20
        }
        expect(subject).to eq(result)
      end
    end
    context "when the type of the data_content_type is image/bmp," do
      let(:data_content_type) { "image/bmp" }
      let(:data_file_name) { "file_name_1.bmp" }
      it "return spot data" do
        result = {
          element: "#{analysis.name} <analysis #{analysis.global_id}>",
          analysis_id: analysis.global_id,
          image_id: attachment_file.global_id,
          image_path: attachment_file.data.url,
          lat: nil,
          lng: nil,
          sample_id: analysis.specimen.global_id,
          surface_id: nil,
          x_image: 10,
          y_image: 20
        }
        expect(subject).to eq(result)
      end
    end
    context "when spot has spot_world_xy," do
      let(:data_content_type) { "image/bmp" }
      let(:data_file_name) { "file_name_1.bmp" }
      let(:world_x) { 50 }
      it "return spot data" do
        result = {
          element: "#{analysis.name} <analysis #{analysis.global_id}>",
          analysis_id: analysis.global_id,
          image_id: attachment_file.global_id,
          image_path: attachment_file.data.url,
          lat: nil,
          lng: nil,
          sample_id: analysis.specimen.global_id,
          surface_id: nil,
          x_image: 10,
          y_image: 20,
          x_vs: 50,
          y_vs: 60
        }
        expect(subject).to eq(result)
      end
    end
    context "when attachment_file is nil," do
      let(:attachment_file) { nil }
      it "return blank" do
        expect(subject).to be_blank
      end
    end
    context "when spot has analysis," do
      let(:data_content_type) { "image/jpeg" }
      let(:data_file_name) { "file_name_1.jpg" }
      let(:analysis) { FactoryBot.create(:analysis, specimen_id: specimen.id) }
      let(:specimen) { FactoryBot.create(:specimen, place_id: nil) }
      #let(:analysis_to_pmlame) { {element: "name", sample_id: "id", "ana_1" => 1.0, "ana_2" => 2.0} }
      before do
        allow(spot).to receive(:get_analysis).and_return(analysis)
        #allow(analysis).to receive(:to_pmlame).and_return(analysis_to_pmlame)
      end
      it "return spot data" do
        result = {
          element: "#{analysis.name} <analysis #{analysis.global_id}>",
          analysis_id: analysis.global_id,
          image_id: attachment_file.global_id,
          image_path: attachment_file.data.url,
          surface_id: nil,
          x_image: 10,
          y_image: 20,
          lat: nil,
          lng: nil,
          sample_id: specimen.global_id
#          "ana_1" => 1.0,
#          "ana_2" => 2.0
        }
        expect(subject).to eq(result)
      end
    end
  end

end
