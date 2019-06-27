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
      after{ obj.destroy }
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
      after { attachment_file.destroy }
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
    after { obj.destroy }
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

  describe ".save_affine_matrix" do
    let(:user) { FactoryGirl.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }

    before do
      User.current = user
      obj
      obj.affine_matrix_in_string = affine_matrix_in_string
    end
    it { expect{obj.save}.not_to raise_error}
    after { obj.destroy }
  end

  describe ".check_affine_matrix", :current => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
    let(:new_name){ "deleteme.1234.jpg" }
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}

    before do
      User.current = user
      surface_image = double("SurfaceImage")
      allow(surface_image).to receive(:id).and_return(10)
      RotateWorker.should_receive(:perform_async).with(obj.id)
      TileWorker.should_receive(:perform_async).with(10)
      surface_image.should_receive(:update).with(hash_including(:left => left, :upper => upper, :right => right, :bottom => bottom))
      allow(obj).to receive(:surface_images).and_return([surface_image])
      allow(obj).to receive(:bounds).and_return([left,upper,right,bottom])
      #obj.affine_matrix_in_string = affine_matrix_in_string
      #obj.save
    end
    it "change affine_matrix" do
      obj.update_attributes(affine_matrix_in_string: affine_matrix_in_string)
    end
    after { obj.destroy }
  end

  describe ".rename_attached_files_if_needed" do
    let(:user) { FactoryGirl.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
    let(:new_name){ "deleteme.1234.jpg" }

    before do
      User.current = user
      obj
    end
    it "chage data.path" do
      obj.update_attributes(name: new_name)
      expect(File.exist?(obj.data.path)).to be_truthy
    end
    after { obj.destroy }
  end

  describe ".create" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      User.current = user
      obj
      obj.save
    end
    context "with filename include @" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload(file,'image/jpeg')) }
      let(:basename){ "test_image@1"  }
      let(:file){"/files/#{basename}.jpg"}
      it "shoud not replace @ with _" do
        expect(File.basename(obj.data.path,'.*')).to eql(basename)
      end
    end

    context "with filename include +" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload(file,'image/jpeg')) }
      let(:basename){ "test_image+1"  }
      let(:file){"/files/#{basename}.jpg"}
      it "shoud replace + with _" do
        expect(File.basename(obj.data.path,'.*')).to eql("test_image_1")
      end
    end


 #   it {expect(obj.original_geometry).to eq("2352x1568")}
    context "with affine_matrix" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg'), affine_matrix_in_string: affine_matrix_in_string) }
      let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
      it {expect(obj.affine_matrix).not_to be_nil}
    end
    context "without affine_matrix" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
      it {expect(obj.affine_matrix).to be_eql([])}
    end
    after { obj.destroy  } 
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
  describe ".bounds" do
    subject {obj.bounds}
    let(:obj){FactoryGirl.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }

    context "affine_matrix is blank" do
      before {obj.affine_matrix = nil}
      it { expect(subject).to eq [nil, nil, nil, nil] }
    end
    context "affine_matrix is not blank" do
      let(:left){ -5200.24 }
      let(:right){ 3000.13 }
      let(:upper){ 2500.45 }
      let(:bottom){ -1200.45 }
      before do
        obj.stub(:corners_on_world){[[left, 0],[0,upper],[right,0],[0,bottom]]}
      end
      it { expect(subject).to eq [left, upper, right, bottom] }
    end
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

  describe ".surfaces" do
    let(:surface){ FactoryGirl.create(:surface) }
    let(:surface_2){ FactoryGirl.create(:surface) }
    let(:obj){ FactoryGirl.create(:attachment_file, data_content_type: data_content_type)}
    let(:data_content_type) { "image/jpeg" }
    before do
      obj
      surface
      surface_2
      surface.images << obj
      surface_2.images << obj
    end
    it { expect(obj.surfaces.count).to eql(2)}
    context "when surface was destroyed" do
      before do
        surface.destroy
      end
      it { expect(obj.surfaces.count).to eql(1)  }
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

