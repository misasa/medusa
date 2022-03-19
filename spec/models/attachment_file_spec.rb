require "spec_helper"
include ActionDispatch::TestProcess

describe AttachmentFile do

 describe "validates" do
    let(:user){FactoryBot.create(:user)}
    before{User.current = user}
    describe "data" do
      before{obj.save}
      context "is presence" do
        let(:data) { fixture_file_upload("test_image.jpg",'image/jpeg')}
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
      let(:attachment_file) { FactoryBot.build(:attachment_file, name: "name", data_file_name: data_file_name) }
      let(:data_file_name) { "test.jpg" }
      it { expect(subject).to eq data_file_name }
    end
  end

  describe ".path" do
    let(:attachment_file) { FactoryBot.create(:attachment_file, :id => attachment_file_id, :data_file_name => "test.jpg") }
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

  describe ".md5hash" do
    let(:user) { FactoryBot.create(:user) }
    let(:md5hash){ Digest::MD5.hexdigest(File.open("spec/fixtures/files/test_image.jpg", 'rb').read) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
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
    let(:obj) { FactoryBot.create(:attachment_file) }
    before{ obj.data_fingerprint = "test" }
    it {expect(obj.data_fingerprint).to eq("test")}
    after { obj.destroy }
  end

  describe ".save_geometry" do
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.new(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
    before do
      User.current = user
      obj
    end
    it {expect(obj.original_geometry).to eq("2352x1568")}
  end

  describe "corners_on_world_in_string=" do
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
    let(:corners_on_world){ [[1492.8272, 2371.039],[1576.2872, 2368.185],[1573.1728, 2304.961],[1489.7128, 2307.815]]}
    let(:string){ "176.33,46.50:179.07,46.60:178.97,48.67:176.23,48.58" }
    before do
      User.current = user
      obj
      
      obj.corners_on_world_in_string = string
    end
    it { expect(obj.affine_matrix).not_to be_eql([])}
    it { expect{obj.save}.not_to raise_error}
    after { obj.destroy }
  end

  describe "corners_on_world=" do
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
    let(:corners_on_world){ [[1492.8272, 2371.039],[1576.2872, 2368.185],[1573.1728, 2304.961],[1489.7128, 2307.815]]}
    before do
      User.current = user
      obj
      obj.corners_on_world = corners_on_world
    end
    it { expect(obj.affine_matrix).not_to be_eql([])}
    it { expect{obj.save}.not_to raise_error}
    after { obj.destroy }
  end

  describe ".save_affine_matrix" do
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }

    before do
      User.current = user
      obj
      obj.affine_matrix_in_string = affine_matrix_in_string
    end
    it { expect{obj.save}.not_to raise_error}
    after { obj.destroy }
  end

  describe ".check_affine_matrix" do
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
    let(:new_name){ "deleteme.1234.jpg" }
    let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
    let(:affine_matrix_1_in_string){ "[1,0,0;0,1,0;0,0.0,1]" }
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}

    before do
      User.current = user
      surface_image = double("SurfaceImage")
      allow(surface_image).to receive(:id).and_return(10)
      TileWorker.should_receive(:perform_async).with(10)
      surface_image.should_receive(:update).with(hash_including(:left => left, :upper => upper, :right => right, :bottom => bottom))
      allow(obj).to receive(:surface_images).and_return([surface_image])
      allow(obj).to receive(:bounds).and_return([left,upper,right,bottom])
    end

    it "change affine_matrix" do
      obj.update(affine_matrix_in_string: affine_matrix_in_string)
    end

    it "change affine_matrix to one" do
      obj.update(affine_matrix_in_string: affine_matrix_1_in_string)
    end

    after { obj.destroy }
  end

  describe ".rename_attached_files_if_needed" do
    pending("") do
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
    let(:new_name){ "deleteme.1234.jpg" }

    before do
      User.current = user
      obj
    end
    it "change data.path" do
      obj.update(name: new_name)
      expect(File.exist?(obj.data.path)).to be_truthy
    end
    after { obj.destroy }
    end
  end

  describe ".create" do
    let(:user) { FactoryBot.create(:user) }
    before do
      User.current = user
      obj
      obj.save
    end
    context "with filename include @" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload(file,'image/jpeg')) }
      let(:basename){ "test_image@1"  }
      let(:file){"#{basename}.jpg"}
      it "shoud not replace @ with _" do
        expect(File.basename(obj.data.path,'.*')).to eql(basename)
      end
    end

    context "with filename include +" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload(file,'image/jpeg')) }
      let(:basename){ "test_image+1"  }
      let(:file){"#{basename}.jpg"}
      it "shoud replace + with _" do
        expect(File.basename(obj.data.path,'.*')).to eql("test_image_1")
      end
    end


 #   it {expect(obj.original_geometry).to eq("2352x1568")}
    context "with affine_matrix" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload("test_image.jpg",'image/jpeg'), affine_matrix_in_string: affine_matrix_in_string) }
      let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
      it {expect(obj.affine_matrix).not_to be_nil}
    end
    context "without affine_matrix" do
      let(:obj) { AttachmentFile.new(data: fixture_file_upload("test_image.jpg",'image/jpeg')) }
      it {expect(obj.affine_matrix).to be_eql([])}
    end
    after { obj.destroy  }
  end

  describe "#fits?" do
    subject { obj.fits_file? }
    let(:obj) { FactoryBot.build(:attachment_file, data_content_type: data_content_type, data_file_name: data_file_name) }
    context "data_content_type is octet-stream" do
      let(:data_content_type) { "application/octet-stream" }
      let(:data_file_name) { "test.fits" }
      it { expect(subject).to eq true }
    end

    context "data_content_type is octet-stream" do
      let(:data_content_type) { "application/octet-stream" }
      let(:data_file_name) { "test.ext" }
      it { expect(subject).to eq false }
    end

    context "data_content_type is pdf" do
      let(:data_content_type) { "application/pdf" }
      let(:data_file_name) { "test.pdf" }
      it { expect(subject).to eq false }
    end
    context "data_content_type is jpeg" do
      let(:data_content_type) { "image/jpeg" }
      let(:data_file_name) { "test.jpg" }
      it { expect(subject).to eq false }
    end
    context "data_content_type is excel" do
      let(:data_content_type) { "application/vnd.ms-excel" }
      let(:data_file_name) { "test.xsl" }
      it { expect(subject).to eq false }
    end
  end

  describe "generate_analysis" do
    subject { obj.analysis }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(subject).not_to be_nil }
  end

  describe "local_path" do
    subject { obj.local_path(:png) }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(File.exists? subject).to be_truthy }
  end


  describe "png_path" do
    subject { obj.png_path }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(File.exists? subject).to be_truthy }
  end

  describe "png_url" do
    subject { obj.png_url(:thumb) }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(subject).to be_truthy }
  end

  describe "fits_data" do
    subject { obj.fits_data }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(subject).to be_an_instance_of(Array) }
  end

  describe "fits_info" do
    subject { obj.fits_info }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(subject[:mean]).not_to be_nil }
    it { expect(subject[:sigma]).not_to be_nil }
  end

  describe "default_display_range" do
    subject { obj.default_display_range }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(subject).to be_an_instance_of(Array) }
  end

  describe "fits_image" do
    subject { obj.fits_image(params) }
    let(:params){ { r_min: 0.1, r_max: 0.5, color_map:'viridis' }}
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    it { expect(subject).to be_an_instance_of(ChunkyPNG::Image) }
  end

  describe "fits2png" do
    subject { obj.fits2png(params) }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    before do
      User.current = user
      obj
    end
    context "with known colormap" do
      let(:params){ { r_min: 0.1, r_max: 0.5, color_map:'viridis' }}
      it { expect{subject}.not_to raise_error }
    end
    context "with unknown colormap" do
      let(:params){ { r_min: 0.1, r_max: 0.5, color_map:'jet' }}
      it { expect{subject}.not_to raise_error }
    end
    context "with no colormap" do
      let(:params){ { r_min: 0.1, r_max: 0.5 }}
      it { expect{subject}.not_to raise_error }
    end
    context "with empty colormap" do
      let(:params){ { r_min: 0.1, r_max: 0.5, color_map:'' }}
      it { expect{subject}.not_to raise_error }
    end
    context "with nil colormap" do
      let(:params){ { r_min: 0.1, r_max: 0.5, color_map: nil }}
      it { expect{subject}.not_to raise_error }
    end

  end

  describe ".colormap" do
    subject { AttachmentFile.colormap(1.0/256) }
    let(:user) { FactoryBot.create(:user) }
    let(:obj) { AttachmentFile.create(data: fixture_file_upload("test_image.fits",'application/octet-stream')) }
    it { expect(AttachmentFile.colormap(1.0/256)).to eql(255)}
    it { expect(AttachmentFile.colormap(nil)).to eql(255)}

  end

  describe "#pdf?" do
    subject { obj.pdf? }
    let(:obj) { FactoryBot.build(:attachment_file, data_content_type: data_content_type) }
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
    let(:obj) { FactoryBot.build(:attachment_file, data_content_type: data_content_type) }
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
    let(:obj){FactoryBot.create(:attachment_file)}
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
    let(:obj){FactoryBot.create(:attachment_file)}
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
    let(:obj){FactoryBot.create(:attachment_file)}
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
    let(:obj){FactoryBot.create(:attachment_file)}
    subject{obj.height_in_um}
    context "affine_matrix is blank" do
      before{obj.affine_matrix = nil}
      it {expect(subject).to eq nil}
    end
    context "affine_matrix is not blank" do
      it {expect(subject).to eq 100.0}
    end
  end

  describe ".transform_points" do
    subject { obj.send(:transform_points, points)  }
    let(:obj){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}

    context "apply points with affine_matrix" do
      let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
      let(:points){[[-50,40],[50,-40]]}
      it {expect(obj.send(:transform_points, points)[0][0]).to be_within(0.01).of(-5694.6)}
      it {expect(obj.send(:transform_points, points)[0][1]).to be_within(0.01).of(2800.919)}
      it {expect(obj.send(:transform_points, points)[1][0]).to be_within(0.01).of(5297.4)}
      it {expect(obj.send(:transform_points, points)[1][1]).to be_within(0.01).of(-2868.48)}

    end

    context "apply points with perspective transform matrix" do
      let(:affine_matrix_in_string){ "[1.50767e+00,4.33427e-01,1.53261e+03;1.00274e+00,1.37592e+00,2.33891e+03;4.47704e-04,2.50842e-04,1.00000e+00]" }
      let(:points){[[-50,40],[50,-40]]}
      it {expect(obj.send(:transform_points, points)[0][0]).to be_within(0.01).of(1493.008)}
      it {expect(obj.send(:transform_points, points)[0][1]).to be_within(0.01).of(2373.12)}
      it {expect(obj.send(:transform_points, points)[1][0]).to be_within(0.01).of(1571.25)}
      it {expect(obj.send(:transform_points, points)[1][1]).to be_within(0.01).of(2305.53)}
    end
  end

  describe ".affine_transform" do
#    subject { obj.affine_transform(x,y)}
    let(:obj){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}
    context "with affine_matrix apply (-50,40)" do
      let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
      let(:x){ -50 }
      let(:y){ 40 }
      it {expect(obj.affine_transform(x,y)[0]).to be_within(0.01).of(-5694.6)}
      it {expect(obj.affine_transform(x,y)[1]).to be_within(0.01).of(2800.919)}
    end
    context "with affine_matrix apply (50,-40)" do
      let(:affine_matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
      let(:x){ 50 }
      let(:y){ -40 }
      it {expect(obj.affine_transform(x,y)[0]).to be_within(0.01).of(5297.4)}
      it {expect(obj.affine_transform(x,y)[1]).to be_within(0.01).of(-2868.48)}
    end
    context "with perspective transform matrix" do
      let(:affine_matrix_in_string){ "[1.50767e+00,4.33427e-01,1.53261e+03;1.00274e+00,1.37592e+00,2.33891e+03;4.47704e-04,2.50842e-04,1.00000e+00]" }
      let(:x){ -50 }
      let(:y){ 40 }

      it {expect(obj.affine_transform(x,y)[0]).to be_within(0.01).of(1493.008)}
      it {expect(obj.affine_transform(x,y)[1]).to be_within(0.01).of(2373.1236)}
    end
  end


  describe ".pixel_pairs_on_world" do
    subject { obj.world_pairs_on_pixel( obj.pixel_pairs_on_world(pixel_pairs) ) }
    let(:obj){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}
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
    let(:obj){FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => affine_matrix_in_string)}
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
    let(:obj){FactoryBot.create(:attachment_file)}
    context "affine_matrix is blank" do
      before{obj.affine_matrix = nil}
      it {expect(subject).to eq nil}
    end
    context "affine_matrix is not blank" do

      it {expect(subject).to eq "[1.00000e+00,0.00000e+00,0.00000e+00;0.00000e+00,1.00000e+00,0.00000e+00;0.00000e+00,0.00000e+00,1.00000e+00]" }
    end
  end

  describe ".surfaces" do
    let(:surface){ FactoryBot.create(:surface) }
    let(:surface_2){ FactoryBot.create(:surface) }
    let(:obj){ FactoryBot.create(:attachment_file, data_content_type: data_content_type)}
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
    let(:obj){FactoryBot.create(:attachment_file)}
    let(:analysis){FactoryBot.create(:analysis)}
    let(:spot){FactoryBot.create(:spot, :target_uid => analysis.global_id)}
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

  describe "rotate" do
    subject{obj.rotate}
    let(:obj){FactoryBot.create(:attachment_file, affine_matrix: [9.5e+01,-1.8e+01,-2.0e+02,1.8e+01,9.4e+01,-3.3e+01,0,0,1])}
    before do
      allow(obj).to receive(:local_path).and_return(File.join(fixture_path, "/files/test_image.jpg"))
    end
    it { expect{subject}.not_to raise_error }
    it { expect(subject).to be_instance_of(String) }
    it { expect(File.exists?(subject)).to be_truthy}
  end

end

