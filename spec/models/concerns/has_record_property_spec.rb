require "spec_helper"

class HasRecordPropertySpec < ActiveRecord::Base
  include HasRecordProperty
end

class HasRecordPropertySpecMigration < ActiveRecord::Migration
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
    let(:record_property) { obj.build_record_property(global_id: global_id, published: published, published_at: published_at) }
    let(:global_id) { "12345" }
    let(:published) { true }
    let(:published_at) { Time.now }
    let(:readable) { true }
    let(:json) { "json" }
    before do
      allow(record_property).to receive(:readable?).and_return(readable)
    end
    it { expect(obj.global_id).to eq global_id }
    it { expect(obj.published).to eq published }
    it { expect(obj.published_at).to eq published_at }
    it { expect(obj.readable?).to be_truthy }
    it { expect(obj.to_json).to include "\"global_id\":\"#{global_id}\"" }
    it { expect(obj.to_xml).to include "<global-id>#{global_id}</global-id>" }
    it { expect(obj.latex_mode).to match /<.* #{global_id}>/}
    #it { expect(obj.latex_mode).to include "<last-modified: #{obj.updated_at}>"}
    #it { expect(obj.latex_mode).to include "<created: #{obj.created_at}>"}        
  end

  describe "#specimen_count" do
    subject { obj.specimen_count }
    before do
      obj
    end
    context "for Specimen" do
      let(:obj) { FactoryGirl.create(:specimen) }
      context "without specimen" do
        it { expect(subject).to eq(0) }
      end
      context "with a specimen" do
        let(:specimen1) { FactoryGirl.create(:specimen)}
        before do
          obj.specimens << specimen1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 specimens" do
        let(:specimen1) { FactoryGirl.create(:specimen)}
        let(:specimen2) { FactoryGirl.create(:specimen)}
        before do
          obj.specimens << specimen1
          obj.specimens << specimen2
        end
        it { expect(subject).to eq(2) }
      end
    end
    context "for Box" do
      let(:obj) { FactoryGirl.create(:box) }
      context "without specimen" do
        it { expect(subject).to eq(0) }
      end
      context "with a specimen" do
        let(:specimen1) { FactoryGirl.create(:specimen)}
        before do
          obj.specimens << specimen1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 specimens" do
        let(:specimen1) { FactoryGirl.create(:specimen)}
        let(:specimen2) { FactoryGirl.create(:specimen)}
        before do
          obj.specimens << specimen1
          obj.specimens << specimen2
        end
        it { expect(subject).to eq(2) }
      end
    end

    context "for Analysis" do
      let(:obj) { FactoryGirl.create(:analysis) }
      context "without specimen" do
        before do
          obj.specimen = nil
        end
        it { expect(subject).to eq(0) }
      end
      context "with a specimen" do
        let(:specimen1) { FactoryGirl.create(:specimen)}
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
      let(:obj) { FactoryGirl.create(:specimen) }
      context "without box" do
        before do
          obj.box = nil
        end
        it { expect(subject).to eq(0) }
      end
      context "with a box" do
        let(:box1) { FactoryGirl.create(:box)}
        before do
          obj.box = box1
        end
        it { expect(subject).to eq(1) }
      end
    end
    context "for Box" do
      let(:obj) { FactoryGirl.create(:box) }
      context "without box" do
        it { expect(subject).to eq(0) }
      end
      context "with a box" do
        let(:box1) { FactoryGirl.create(:box)}
        before do
          obj.boxes << box1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 boxes" do
        let(:box1) { FactoryGirl.create(:box)}
        let(:box2) { FactoryGirl.create(:box)}
        before do
          obj.boxes << box1
          obj.boxes << box2
        end
        it { expect(subject).to eq(2) }
      end
    end
    context "for Bib" do
      let(:obj) { FactoryGirl.create(:bib) }
      context "without box" do
        it { expect(subject).to eq(0) }
      end
      context "with a box" do
        let(:box1) { FactoryGirl.create(:box)}
        before do
          obj.boxes << box1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 boxes" do
        let(:box1) { FactoryGirl.create(:box)}
        let(:box2) { FactoryGirl.create(:box)}
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
      let(:obj) { FactoryGirl.create(:specimen) }
      context "without file" do
        it { expect(subject).to eq(0) }
      end
      context "with a file" do
        let(:file1) { FactoryGirl.create(:attachment_file)}
        before do
          obj.attachment_files << file1
        end
        it { expect(subject).to eq(1) }
      end
      context "with 2 files" do
        let(:file1) { FactoryGirl.create(:attachment_file)}
        let(:file2) { FactoryGirl.create(:attachment_file)}
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
       let(:obj) { FactoryGirl.create(:specimen) }
#       it { expect(subject).to match /\/#{obj.name} <specimen: #{obj.global_id}> <link: specimen=\d+ box=\d+ analysis=\d+ file=\d+ bib=\d+ locality=\d+ point=\d+> <last-modified: #{obj.updated_at}> <created: #{obj.created_at}>/}
       it { expect(subject).to match /\/#{obj.name} <specimen #{obj.global_id}>/}
     end
     context "for Box" do
       let(:obj) { FactoryGirl.create(:box) }
#       it { expect(subject).to match /\/#{obj.name} <box: #{obj.global_id}> <link: specimen=\d+ box=\d+ analysis=\d+ file=\d+ bib=\d+ locality=\d+ point=\d+> <last-modified: #{obj.updated_at}> <created: #{obj.created_at}>/}
       it { expect(subject).to match /\/#{obj.name} <box #{obj.global_id}>/}
     end
     context "for Bib" do
       let(:obj) { FactoryGirl.create(:bib) }
#       it { expect(subject).to match /\/#{obj.name} <bib: #{obj.global_id}> <link: specimen=\d+ box=\d+ analysis=\d+ file=\d+ bib=\d+ locality=\d+ point=\d+> <last-modified: #{obj.updated_at}> <created: #{obj.created_at}>/}
       it { expect(subject).to match /\/#{obj.name} <bib #{obj.global_id}>/}
     end
  end

  describe "#to_bibtex" do
    subject { obj.to_bibtex }
    context "bib" do
      let(:obj) { FactoryGirl.create(:bib, entry_type: entry_type, abbreviation: abbreviation) }
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
        let(:obj) { FactoryGirl.create(:specimen, name: name) }
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
    let(:user) { FactoryGirl.create(:user_foo, administrator: admin) }
    let(:admin) { false }
    let(:group) { FactoryGirl.create(:group) }
    let(:another_user) { FactoryGirl.create(:user_baa) }
    let(:another_group) { FactoryGirl.create(:group) }
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
    let(:user) { FactoryGirl.create(:user_foo) }
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
        let(:user) { FactoryGirl.create(:user) }
        let(:specimen) { FactoryGirl.build(:specimen) }
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
          let(:specimen) { FactoryGirl.create(:specimen, name: name) }
          let(:name) { "specimen" }
          before { specimen }
          it { expect(specimen.record_property).to be_present }
          it { expect(specimen.record_property.name).to eq name }
        end
        context "name attribute isn't exist" do
          let(:chemistry) { FactoryGirl.create(:chemistry) }
          before { chemistry }
          it { expect(chemistry.record_property).to be_present }
          it { expect(chemistry.record_property.name).to be_nil }
        end
      end
    end

    describe ".user_id=" do
      let(:specimen) { FactoryGirl.create(:specimen) }
      let(:user_id){999}
      before{specimen.user_id = user_id}
      it { expect(specimen.user_id).to eq user_id}
    end

    describe ".group_id=" do
      let(:specimen) { FactoryGirl.create(:specimen) }
      let(:group_id){999}
      before{specimen.group_id = group_id}
      it { expect(specimen.group_id).to eq group_id}
    end

  end

end
