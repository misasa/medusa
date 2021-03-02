require "spec_helper"

class HasRecordPropertySpec < ApplicationRecord
  include HasRecordProperty
end

class HasRecordPropertySpecMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :has_record_property_specs do |t|
      t.string :name
      t.timestamps
    end
  end
  def self.down
    drop_table :has_record_property_specs
  end
end

describe HasRecordProperty do
  let(:klass) { HasRecordPropertySpec }
  let(:migration) { HasRecordPropertySpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }

  describe "deligate methods" do
    let(:obj) { klass.create(name: "foo") }
    let(:record_property) { obj.build_record_property(global_id: global_id, published: published, published_at: published_at, disposed: disposed, disposed_at: disposed_at, lost: lost, lost_at: lost_at) }
    let(:global_id) { "12345" }
    let(:published) { true }
    let(:published_at) { Time.now }
    let(:disposed) { true }
    let(:disposed_at) { Time.now }
    let(:lost) { true }
    let(:lost_at) { Time.now }
    let(:readable) { true }
    let(:json) { "json" }
    before do
      allow(record_property).to receive(:readable?).and_return(readable)
    end
    it { expect(obj.global_id).to eq global_id }
    it { expect(obj.published).to eq published }
    it { expect(obj.published_at).to eq published_at }
    it { expect(obj.disposed).to eq disposed }
    it { expect(obj.disposed_at).to eq disposed_at }
    it { expect(obj.lost).to eq lost }
    it { expect(obj.lost_at).to eq lost_at }
    it { expect(obj.readable?).to be_truthy }
    it { expect(obj.to_json).to include "\"global_id\":\"#{global_id}\"" }
    it { expect(obj.to_xml).to include "<global-id>#{global_id}</global-id>" }
    it { expect(obj.latex_mode).to match /<.* #{global_id}>/}
    #it { expect(obj.latex_mode).to include "<last-modified: #{obj.updated_at}>"}
    #it { expect(obj.latex_mode).to include "<created: #{obj.created_at}>"}
  end

  describe "#spot_links" do
    let(:file) { FactoryBot.create(:attachment_file)}
    let(:spot) { FactoryBot.create(:spot, attachment_file: file)}

    subject { obj.spot_links }
    before do
      obj
    end
    context "for Specimen" do
      let(:obj) { FactoryBot.create(:specimen)}
      let(:spot) { FactoryBot.create(:spot, attachment_file: file, target_uid: obj.global_id) }
      before do
        spot
      end
      it { expect(subject).to eq([spot]) }
    end
  end

  describe "#specimen_count" do
    subject { obj.specimen_count }
    before do
      obj
    end
    context "for Specimen" do
      let(:obj) { FactoryBot.create(:specimen) }
      context "without specimen" do
        it { expect(subject).to eq(0) }
      end
      context "with a specimen" do
        let(:specimen1) { FactoryBot.create(:specimen)}
        before do
          obj.specimens << specimen1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 specimens" do
        let(:specimen1) { FactoryBot.create(:specimen)}
        let(:specimen2) { FactoryBot.create(:specimen)}
        before do
          obj.specimens << specimen1
          obj.specimens << specimen2
        end
        it { expect(subject).to eq(2) }
      end
    end
    context "for Box" do
      let(:obj) { FactoryBot.create(:box) }
      context "without specimen" do
        it { expect(subject).to eq(0) }
      end
      context "with a specimen" do
        let(:specimen1) { FactoryBot.create(:specimen)}
        before do
          obj.specimens << specimen1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 specimens" do
        let(:specimen1) { FactoryBot.create(:specimen)}
        let(:specimen2) { FactoryBot.create(:specimen)}
        before do
          obj.specimens << specimen1
          obj.specimens << specimen2
        end
        it { expect(subject).to eq(2) }
      end
    end

    context "for Analysis" do
      let(:obj) { FactoryBot.create(:analysis) }
      context "without specimen" do
        before do
          obj.specimen = nil
        end
        it { expect(subject).to eq(0) }
      end
      context "with a specimen" do
        let(:specimen1) { FactoryBot.create(:specimen)}
        before do
          obj.specimen = specimen1
        end
        it { expect(subject).to eq(1) }
      end
    end
  end

  describe "#box_count" do
    subject { obj.box_count }
    before do
      obj
    end
    context "for Specimen" do
      let(:obj) { FactoryBot.create(:specimen) }
      context "without box" do
        before do
          obj.box = nil
        end
        it { expect(subject).to eq(0) }
      end
      context "with a box" do
        let(:box1) { FactoryBot.create(:box)}
        before do
          obj.box = box1
        end
        it { expect(subject).to eq(1) }
      end
    end
    context "for Box" do
      let(:obj) { FactoryBot.create(:box) }
      context "without box" do
        it { expect(subject).to eq(0) }
      end
      context "with a box" do
        let(:box1) { FactoryBot.create(:box)}
        before do
          obj.boxes << box1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 boxes" do
        let(:box1) { FactoryBot.create(:box)}
        let(:box2) { FactoryBot.create(:box)}
        before do
          obj.boxes << box1
          obj.boxes << box2
        end
        it { expect(subject).to eq(2) }
      end
    end
    context "for Bib" do
      let(:obj) { FactoryBot.create(:bib) }
      context "without box" do
        it { expect(subject).to eq(0) }
      end
      context "with a box" do
        let(:box1) { FactoryBot.create(:box)}
        before do
          obj.boxes << box1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 boxes" do
        let(:box1) { FactoryBot.create(:box)}
        let(:box2) { FactoryBot.create(:box)}
        before do
          obj.boxes << box1
          obj.boxes << box2
        end
        it { expect(subject).to eq(2) }
      end
    end
  end

  describe "#attachment_file_count" do
    subject { obj.attachment_file_count }
    before do
      obj
    end
    context "for Specimen" do
      let(:obj) { FactoryBot.create(:specimen) }
      context "without file" do
        it { expect(subject).to eq(0) }
      end
      context "with a file" do
        let(:file1) { FactoryBot.create(:attachment_file)}
        before do
          obj.attachment_files << file1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 files" do
        let(:file1) { FactoryBot.create(:attachment_file)}
        let(:file2) { FactoryBot.create(:attachment_file)}
        before do
          obj.attachment_files << file1
          obj.attachment_files << file2
        end
        it { expect(subject).to eq(2) }
      end
    end
  end

  describe "#latex_mode" do
     subject { obj.latex_mode }
     before do
        obj
     end
     context "for Specimen" do
       let(:obj) { FactoryBot.create(:specimen) }
#       it { expect(subject).to match /\/#{obj.name} <specimen: #{obj.global_id}> <link: specimen=\d+ box=\d+ analysis=\d+ file=\d+ bib=\d+ locality=\d+ point=\d+> <last-modified: #{obj.updated_at}> <created: #{obj.created_at}>/}
       it { expect(subject).to match /\/#{obj.name} <specimen #{obj.global_id}>/}
     end
     context "for Box" do
       let(:obj) { FactoryBot.create(:box) }
#       it { expect(subject).to match /\/#{obj.name} <box: #{obj.global_id}> <link: specimen=\d+ box=\d+ analysis=\d+ file=\d+ bib=\d+ locality=\d+ point=\d+> <last-modified: #{obj.updated_at}> <created: #{obj.created_at}>/}
       it { expect(subject).to match /\/#{obj.name} <box #{obj.global_id}>/}
     end
     context "for Bib" do
       let(:obj) { FactoryBot.create(:bib) }
#       it { expect(subject).to match /\/#{obj.name} <bib: #{obj.global_id}> <link: specimen=\d+ box=\d+ analysis=\d+ file=\d+ bib=\d+ locality=\d+ point=\d+> <last-modified: #{obj.updated_at}> <created: #{obj.created_at}>/}
       it { expect(subject).to match /\/#{obj.name} <bib #{obj.global_id}>/}
     end
  end

  describe "#to_bibtex" do
    subject { obj.to_bibtex }
    context "bib" do
      let(:obj) { FactoryBot.create(:bib, entry_type: entry_type, abbreviation: abbreviation) }
      describe "@article" do
        before do
          obj
          allow(obj).to receive(:article_tex).and_return("test")
        end
        let(:entry_type) { "article" }
        context "abbreviation is not nil" do
          let(:abbreviation) { "abbreviation" }
          it { expect(subject).to eq "\n@article{#{obj.global_id},\ntest,\n}" }
        end
        context "abbreviation is nil" do
          let(:abbreviation) { "" }
          it { expect(subject).to eq "\n@article{#{obj.global_id},\ntest,\n}" }
        end
      end
      context "specimen" do
        let(:obj) { FactoryBot.create(:specimen, name: name) }
        let(:name) { "specimen" }
        describe "@specimen" do
          before do
            obj
          end
          it { expect(subject).to include "@article{#{obj.global_id}" }
        end
      end
    end
  end

  describe ".readables" do
    subject { HasRecordPropertySpec.readables(user) }
    let(:obj) { klass.create(name: "foo") }
    let(:user) { FactoryBot.create(:user_foo, administrator: admin) }
    let(:admin) { false }
    let(:group) { FactoryBot.create(:group) }
    let(:another_user) { FactoryBot.create(:user_baa) }
    let(:another_group) { FactoryBot.create(:group) }
    before do
      GroupMember.create(user: user, group: group)
      obj.create_record_property(owner_readable: owner_readable, group_readable: group_readable, guest_readable: guest_readable, user_id: user_id, group_id: group_id)
    end
    context "when user is record owner." do
      let(:user_id) { user.id }
      let(:group_id) { another_group.id }
      let(:group_readable) { false }
      let(:guest_readable) { false }
      context "when owner is permitted to read." do
        let(:owner_readable) { true }
        it { expect(subject).to be_present }
      end
      context "when owner is not permitted to read." do
        let(:owner_readable) { false }
        it { expect(subject).to be_blank }
        context "when user is administrator." do
          let(:admin) { true }
          it { expect(subject).to be_present }
        end
      end
    end
    context "when user is not record owner." do
      let(:user_id) { another_user.id }
      let(:owner_readable) { true }
      context "when user belongs to record group." do
        let(:group_id) { group.id }
        let(:guest_readable) { false }
        context "when group member is permitted to read." do
          let(:group_readable) { true }
          it { expect(subject).to be_present }
        end
        context "when group member is not permitted to read." do
          let(:group_readable) { false }
          it { expect(subject).to be_blank }
          context "when user is administrator." do
            let(:admin) { true }
            it { expect(subject).to be_present }
          end
        end
      end
      context "when user does not belongs to record group." do
        let(:group_id) { another_group.id }
        let(:group_readable) { true }
        context "when guest is permitted to read." do
          let(:guest_readable) { true }
          it { expect(subject).to be_present }
        end
        context "when guest is not permitted to read." do
          let(:guest_readable) { false }
          it { expect(subject).to be_blank }
          context "when user is administrator." do
            let(:admin) { true }
            it { expect(subject).to be_present }
          end
        end
      end
    end
  end

  describe "#writable?" do
    subject { obj.writable?(user) }
    let(:obj) { klass.create(name: "foo") }
    let(:user) { FactoryBot.create(:user_foo) }
    before { obj.create_record_property }
    context "when obj is new_record." do
      before { allow(obj).to receive(:new_record?).and_return(true) }
      context "when record_property is writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(true) }
        it { expect(subject).to eq true }
      end
      context "when record_property isn't writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(false) }
        it { expect(subject).to eq true }
      end
    end
    context "when obj isn't new_record." do
      before { allow(obj).to receive(:new_record?).and_return(false) }
      context "when record_property is writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(true) }
        it { expect(subject).to eq true }
      end
      context "when record_property isn't writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(false) }
        it { expect(subject).to eq false }
      end
    end
  end

  describe "callbacks" do
    describe "after_create" do
      describe "generate_record_property" do
        let(:user) { FactoryBot.create(:user) }
        let(:specimen) { FactoryBot.build(:specimen) }
        before do
          User.current = user
          specimen.save
        end
        it{ expect(specimen.record_property).to be_present }
        it{ expect(specimen.record_property).to be_persisted }
      end
    end
    describe "after_save" do
      describe "update_record_property" do
        context "name attribute is exist" do
          let(:specimen) { FactoryBot.create(:specimen, name: name) }
          let(:name) { "specimen" }
          before { specimen }
          it { expect(specimen.record_property).to be_present }
          it { expect(specimen.record_property.name).to eq name }
        end
        context "name attribute isn't exist" do
          let(:chemistry) { FactoryBot.create(:chemistry) }
          before { chemistry }
          it { expect(chemistry.record_property).to be_present }
          it { expect(chemistry.record_property.name).to be_nil }
        end
      end
    end

    describe ".disposal_or_loss?" do
      let(:specimen){ FactoryBot.create(:specimen) }
      let(:user) { FactoryBot.create(:user) }
      before do
        User.current = user
        specimen.record_property.lost = lost
        specimen.record_property.disposed = disposed
        specimen.save!
      end
      subject { specimen.disposal_or_loss? }
      context "lost = false, disposed = false" do
        let(:lost) { false }
        let(:disposed) { false }
        it { expect(subject).to eq false }
      end
      context "lost = true, disposed = false" do
        let(:lost) { true }
        let(:disposed) { false }
        it { expect(subject).to eq true }
      end
      context "lost = false, disposed = true" do
        let(:lost) { false }
        let(:disposed) { true }
        it { expect(subject).to eq true }
      end
      context "lost = true, disposed = true" do
        let(:lost) { true }
        let(:disposed) { true }
        it { expect(subject).to eq true }
      end
    end

    describe ".dispose" do
      let(:specimen){ FactoryBot.create(:specimen) }
      let(:user) { FactoryBot.create(:user) }
      before do
        User.current = user
        specimen.dispose
      end
      it { expect(specimen.record_property.disposed).to eq true }
      it { expect(specimen.record_property.disposed_at).to be_present }
    end

    describe ".restore" do
      let(:specimen){ FactoryBot.create(:specimen) }
      let(:user) { FactoryBot.create(:user) }
      before do
        User.current = user
        specimen.record_property.disposed = true
        specimen.record_property.disposed_at = "2016-10-10 12:13:14"
        specimen.record_property.save!
        specimen.restore
      end
      it { expect(specimen.record_property.disposed).to eq false }
      it { expect(specimen.record_property.disposed_at).to be_nil }
    end

    describe ".user_id=" do
      let(:specimen) { FactoryBot.create(:specimen) }
      let(:user_id){999}
      before{specimen.user_id = user_id}
      it { expect(specimen.user_id).to eq user_id}
    end

    describe ".group_id=" do
      let(:specimen) { FactoryBot.create(:specimen) }
      let(:group_id){999}
      before{specimen.group_id = group_id}
      it { expect(specimen.group_id).to eq group_id}
    end

    describe ".disposed=" do
      let(:specimen) { FactoryBot.create(:specimen) }
      let(:disposed){ true }
      before { specimen.disposed = disposed }
      it { expect(specimen.disposed).to eq disposed }
    end

    describe ".lost=" do
      let(:specimen) { FactoryBot.create(:specimen) }
      let(:lost){ true }
      before { specimen.lost = lost }
      it { expect(specimen.lost).to eq lost }
    end
  end

  describe "#build_pmlame" do
    subject{ obj.build_pmlame([]) }
    let(:obj) { FactoryBot.create(:specimen)}
    let(:analysis_1) { FactoryBot.create(:analysis) }
    let(:analysis_2) { FactoryBot.create(:analysis, name: "分類2") }
    let!(:spot_1) { FactoryBot.create(:spot, target_uid: analysis_1.try(:global_id) ) }
    let(:pml_elements) { [] }

    before do
      @spot_1_pmlame = {
        image_id: "global_id_spot_1",
        image_path: "image_path_spot_1",
        x_image: 1, y_image: 2,
      }
      @analysis_1_pmlame = {
        element: analysis_1.name,
        sample_id: "global_id_ana_1",
        "Ti" => 10, "Ti_error" => 11,
        "C" => 12, "C_error" => 13,
      }
      @analysis_2_pmlame = {
        element: analysis_2.name,
        sample_id: "global_id_ana_2",
        "P" => 14, "P_error" => 15,
      }
      allow(obj).to receive(:pml_elements).and_return(pml_elements)
      allow_any_instance_of(Spot).to receive(:to_pmlame).and_return(@spot_1_pmlame)
      allow(analysis_1).to receive(:to_pmlame).and_return(@analysis_1_pmlame)
      allow(analysis_2).to receive(:to_pmlame).and_return(@analysis_2_pmlame)
    end
    context "when pml_elements and spot is exist, " do
      let(:pml_elements) { [analysis_1, analysis_2] }
      it do
        result = [@analysis_1_pmlame.merge(@spot_1_pmlame), @analysis_2_pmlame]
        expect(subject).to match_array(result)
      end
    end
    context "when only pml_elements is exist and spot is not exists " do
      let(:pml_elements) { [analysis_1, analysis_2] }
      let!(:spot_1) { FactoryBot.create(:spot, target_uid: nil ) }
      it do
        result = [@analysis_1_pmlame, @analysis_2_pmlame]
        expect(subject).to match_array(result)
      end
    end
    context "when pml_elements is not exist," do
      let(:pml_elements) { [] }
      it do
        result = []
        expect(subject).to match_array(result)
      end
    end
    context "when pml_elements is exist which has not have to_pmlame method," do
      let(:pml_elements) { [box] }
      let(:box) { FactoryBot.create(:box ) }
      it do
        result = []
        expect(subject).to match_array(result)
      end
    end
  end

  describe "#pml_elements" do
    subject { obj.pml_elements }
    before do
      obj
    end
    context "when datum type is Specimen" do
      let(:obj) { FactoryBot.create(:specimen)}
      let(:analysis_1) { FactoryBot.create(:analysis) }
      let(:analysis_2) { FactoryBot.create(:analysis, name: "分類2") }
      before do
        obj.analyses << analysis_1
        obj.analyses << analysis_2
        obj.analyses << analysis_1
      end
      it { expect(subject).to match_array([analysis_1, analysis_2]) }
    end
    context "when datum type is Place" do
      let(:obj) { FactoryBot.create(:place)}
      let(:specimen) { FactoryBot.create(:specimen) }
      let(:analysis_1) { FactoryBot.create(:analysis) }
      let(:analysis_2) { FactoryBot.create(:analysis, name: "分類2") }
      before do
        specimen.analyses << analysis_1
        specimen.analyses << analysis_2
        obj.specimens << specimen
      end
      it { expect(subject).to match_array([analysis_1, analysis_2]) }
    end
    context "when datum type is Chemistry" do
      let(:obj) { FactoryBot.create(:chemistry)}
      let(:analysis_1) { FactoryBot.create(:analysis) }
      let(:analysis_2) { FactoryBot.create(:analysis, name: "分類2") }
      before do
        obj.analysis = analysis_1
      end
      it { expect(subject).to match_array([analysis_1]) }
    end
    context "when datum type is AttachmentFile" do
      let(:obj) { FactoryBot.create(:attachment_file)}
      let(:analysis_1) { FactoryBot.create(:analysis) }
      let(:analysis_2) { FactoryBot.create(:analysis, name: "分類2") }
      before do
        obj.analyses << analysis_1
        obj.analyses << analysis_2
      end
      it { expect(subject).to match_array([analysis_1, analysis_2]) }
    end
    context "when datum type is Surface" do
      let(:obj) { FactoryBot.create(:surface)}
      let(:spot_1) { FactoryBot.create(:spot) }
      let(:spot_2) { FactoryBot.create(:spot) }
      let(:target_1) { FactoryBot.create(:analysis) }
      let(:target_2) { FactoryBot.create(:spot) }
      before do
        allow(obj).to receive(:spots).and_return([spot_1, spot_2])
        allow(spot_1).to receive(:target).and_return(target_1)
        allow(spot_2).to receive(:target).and_return(target_2)
      end
      it { expect(subject).to match_array([spot_1, spot_2]) }
    end

  end
end
