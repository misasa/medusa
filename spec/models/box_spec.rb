require 'spec_helper'

describe Box do

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:box, name: name) }
      context "is presence" do
        let(:name) { "sample_box_type" }
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
      describe "uniqueness" do
        let(:parent_box) { FactoryGirl.create(:box) }
        let(:child_box) { FactoryGirl.create(:box, name: "box", parent_id: parent_box.id) }
        let(:obj) { FactoryGirl.build(:box, name: "box", parent_id: parent_id) }
        before { child_box }
        context "uniq name with parent" do
          let(:parent_id) { nil }
          it { expect(obj).to be_valid }
        end
        context "duplicate name" do
          let(:parent_id) { parent_box.id }
          it { expect(obj).not_to be_valid }
        end
      end
    end
    describe "parent_id" do
      let(:parent_box) { FactoryGirl.create(:box) }
      let(:box) { FactoryGirl.create(:box, parent_id: parent_id) }
      let(:child_box) { FactoryGirl.create(:box, parent_id: box.id) }
      let(:user) { FactoryGirl.create(:user) }
      before do
        User.current = user
        parent_box
        box
        child_box
      end
      context "is nil" do
        let(:parent_id) { nil }
        it { expect(box).to be_valid }
      end
      context "is present" do
        let(:parent_id) { parent_box.id }
        context "and parent_id equal self.id" do
          before { box.parent_id = box.id }
          it { expect(box).not_to be_valid }
        end
        context "and parent_id equal child_box.id" do
          before { box.parent_id = child_box.id }
          it { expect(box).not_to be_valid }
        end
        context "and valid id" do
          it { expect(box).to be_valid }
        end
      end
    end
  end

  describe "callbacks" do
    describe "after_save" do
      describe "reset_path" do
        let(:box) { FactoryGirl.build(:box, path: "path", parent_id: parent_id) }
        before { box.save }
        context "box has no parent" do
          let(:parent_id) { nil }
          it { expect(box.path).to eq "" }
        end
        context "box has a parent" do
          let(:parent_id) { parent.id }
          let(:parent) { FactoryGirl.create(:box) }
          it { expect(box.path).to eq "/#{parent.name}" }
        end
        context "box has parent and grand_parent" do
          let(:parent_id) { parent.id }
          let(:parent) { FactoryGirl.create(:box, parent_id: grand_parent.id) }
          let(:grand_parent) { FactoryGirl.create(:box) }
          it { expect(box.path).to eq "/#{grand_parent.name}/#{parent.name}" }
          it { expect(box.box_path).to eq "/#{grand_parent.name}/#{parent.name}/#{box.name}" }
          it { expect(box.blood_path).to eq "/#{grand_parent.name}/#{parent.name}/#{box.name}" }          
        end
      end
    end
  end

  describe "#paths", :current => true do
    let(:box) { FactoryGirl.build(:box, path: "path", parent_id: parent_id, name: 'box') }
    let(:parent_id) { parent.id }
    let(:parent) { FactoryGirl.create(:box, parent_id: grand_parent.id, name: 'parent') }
    let(:grand_parent) { FactoryGirl.create(:box, name: 'grand_parent') }

    before { 
      box.save
     }
    it {
      expect(box.paths).not_to be_empty
    }
  end

  describe "#descendants" do
    let(:root) { FactoryGirl.create(:box, name: "root") }
    let(:child_1){ FactoryGirl.create(:box, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:box, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.descendants).to match_array([child_1, child_1_1])
    }
  end

  describe "#self_and_descendants" do
    let(:root) { FactoryGirl.create(:box, name: "root") }
    let(:child_1){ FactoryGirl.create(:box, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:box, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.self_and_descendants).to match_array([root, child_1, child_1_1])
    }
  end

  describe "analyses" do
    subject{obj.analyses}
    let(:obj){FactoryGirl.create(:box)}
    context "no analysis" do
      before{obj.specimens.clear}
      it { expect(subject.count).to eq 0}
      it { expect(subject).to eq []}
    end

    context "many analysis" do
      let(:analysis){FactoryGirl.create(:analysis)}
      let(:specimen1){FactoryGirl.create(:specimen)}
      let(:specimen2){FactoryGirl.create(:specimen)}
      before do
        obj.specimens.clear
        obj.specimens << specimen1
        obj.specimens << specimen2
        specimen1.analyses << analysis
        specimen1.analyses << analysis
        specimen1.analyses << analysis
        specimen1.analyses << analysis
        specimen1.analyses << analysis
        specimen2.analyses << analysis
        specimen2.analyses << analysis
        specimen2.analyses << analysis
      end
      it { expect(subject.count).to eq (specimen1.analyses.size + specimen2.analyses.size)}
      it { expect(subject).to eq (specimen1.analyses + specimen2.analyses)}
    end
  end
end
