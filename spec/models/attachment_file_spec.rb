require "spec_helper"
include ActionDispatch::TestProcess

describe AttachmentFile do

 describe "validates" do
    let(:user){FactoryGirl.create(:user)}
    before{User.current = user}
    describe "data" do
      before{obj.save}
      context "is presence" do
        let(:data) { fixture_file_upload("/files/test_image.jpg",'image/jpeg')}
        let(:obj){AttachmentFile.new(data: data)}
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:obj){AttachmentFile.new()}
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe "alias_attribute" do
    describe "name" do
      subject { attachment_file.name }
      let(:attachment_file) { FactoryGirl.build(:attachment_file, name: "name", data_file_name: data_file_name) }
      let(:data_file_name) { "test.jpg" }
      it { expect(subject).to eq data_file_name }
    end
  end

  describe ".path" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file, :id => attachment_file_id, :data_file_name => "test.jpg") }
    context "with no argument" do
      subject { attachment_file.path }
      context "id is 1 digit" do
        let(:attachment_file_id) { 1 }
        it { expect(subject).to include("/system/attachment_files/0000/0001/test.jpg") }
      end
      context "id is 4 digits" do
        let(:attachment_file_id) { 1234 }
        it { expect(subject).to include("/system/attachment_files/0000/1234/test.jpg") }
      end
      context "id is 5 digits" do
        let(:attachment_file_id) { 12345 }
        it { expect(subject).to include("/system/attachment_files/0001/2345/test.jpg") }
      end
      context "id is 8 digits" do
        let(:attachment_file_id) { 12345678 }
        it { expect(subject).to include("/system/attachment_files/1234/5678/test.jpg") }
      end
    end
  end

  describe ".md5hash", :current => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:md5hash){ Digest::MD5.hexdigest(File.open("spec/fixtures/files/test_image.jpg", 'rb').read) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
    before do
      User.current = user
      obj
    end
    it {expect(obj.md5hash).to eq(md5hash)}
    after do
      obj.destroy
    end
  end

  describe ".data_fingerprint" do
    let(:obj) { FactoryGirl.create(:attachment_file) }
    before{ obj.data_fingerprint = "test" }
    it {expect(obj.data_fingerprint).to eq("test")}
  end

  describe ".save_geometry" do
    let(:user) { FactoryGirl.create(:user) }
    let(:obj) { AttachmentFile.new(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
    before do
      User.current = user
      obj
    end
    it {expect(obj.original_geometry).to eq("2352x1568")}
  end

  describe "#pdf?" do
    subject { obj.pdf? }
    let(:obj) { FactoryGirl.build(:attachment_file, data_content_type: data_content_type) }
    context "data_content_type is pdf" do
      let(:data_content_type) { "application/pdf" }
      it { expect(subject).to eq true }
    end
    context "data_content_type is jpeg" do
      let(:data_content_type) { "image/jpeg" }
      it { expect(subject).to eq false }
    end
    context "data_content_type is excel" do
      let(:data_content_type) { "application/vnd.ms-excel" }
      it { expect(subject).to eq false }
    end
  end

  describe "#image?" do
    subject { obj.image? }
    let(:obj) { FactoryGirl.build(:attachment_file, data_content_type: data_content_type) }
    context "data_content_type is pdf" do
      let(:data_content_type) { "application/pdf" }
      it { expect(subject).to eq false }
    end
    context "data_content_type is jpeg" do
      let(:data_content_type) { "image/jpeg" }
      it { expect(subject).to eq true }
    end
    context "data_content_type is excel" do
      let(:data_content_type) { "application/vnd.ms-excel" }
      it { expect(subject).to eq false }
    end
  end

  describe ".original_width" do
    let(:obj){FactoryGirl.create(:attachment_file)}
    subject{ obj.original_width }
    before{obj.original_geometry = original_geometry}
    context "original_geometry is blank" do
      let(:original_geometry){nil}
      it {expect(subject).to eq nil}
    end
    context "original_geometry is not blank" do
      let(:original_geometry){"111x222"}
      it {expect(subject).to eq 111}
    end
  end

  describe ".original_height" do
    let(:obj){FactoryGirl.create(:attachment_file)}
    subject{ obj.original_height }
    before{obj.original_geometry = original_geometry}
    context "original_geometry is blank" do
      let(:original_geometry){nil}
      it {expect(subject).to eq nil}
    end
    context "original_geometry is not blank" do
      let(:original_geometry){"111x222"}
      it {expect(subject).to eq 222}
    end
  end

  describe ".width_in_um" do
    let(:obj){FactoryGirl.create(:attachment_file)}
    subject{obj.width_in_um}
    context "affine_matrix is blank" do
      before{obj.affine_matrix = nil}
      it {expect(subject).to eq nil}
    end
    context "affine_matrix is not blank" do
      it {expect(subject).to eq 100.0}
    end
  end

  describe ".height_in_um" do
    let(:obj){FactoryGirl.create(:attachment_file)}
    subject{obj.height_in_um}
    context "affine_matrix is blank" do
      before{obj.affine_matrix = nil}
      it {expect(subject).to eq nil}
    end
    context "affine_matrix is not blank" do
      it {expect(subject).to eq 100.0}
    end
  end

  describe ".affine_transform" do
    subject { obj.affine_transform(x, y)}
    let(:obj){FactoryGirl.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}
    let(:point_1){ [0, 0] }
    let(:x){ 0 }
    let(:y){ 0 }
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
    let(:points){ obj.send(:image_xy2image_coord, *point_1) }
    it {expect(subject).not_to be_empty} 
  end


  describe ".pixel_pairs_on_world" do
    subject { obj.world_pairs_on_pixel( obj.pixel_pairs_on_world(pixel_pairs) ) }
    let(:obj){FactoryGirl.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}
    let(:point_1){ [20, 30] }
    let(:pixel_pairs){ [point_1] }
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
    let(:world){ obj.pixels_on_world(*point_1) }
#    before do
#      p pixel_pairs
#      p subject
#    end
    it {expect(subject).not_to be_empty} 
  end
  describe ".affine_matrix_in_string" do
    subject{obj.affine_matrix_in_string}
    let(:obj){FactoryGirl.create(:attachment_file)}
    context "affine_matrix is blank" do
      before{obj.affine_matrix = nil}
      it {expect(subject).to eq nil}
    end
    context "affine_matrix is not blank" do
      it {expect(subject).to eq "[1.000e+00,0.000e+00,0.000e+00;0.000e+00,1.000e+00,0.000e+00;0.000e+00,0.000e+00,1.000e+00]" }
    end
  end

  describe ".to_pml" do
    subject{[obj].to_pml}
    let(:obj){FactoryGirl.create(:attachment_file)}
    let(:analysis){FactoryGirl.create(:analysis)}
    let(:spot){FactoryGirl.create(:spot, :target_uid => analysis.global_id)}
    before do
      obj
      analysis
      obj.analyses << analysis
      obj.spots << spot
    end

    context "output xml" do
      it {expect(subject).to match(/xml/) }
    end
  end



end

