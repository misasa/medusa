require 'spec_helper'
include ActionDispatch::TestProcess

describe SpecimenDecorator do
  let(:user){FactoryGirl.create(:user)}
  let(:obj){FactoryGirl.create(:specimen).decorate}
  let(:box){FactoryGirl.create(:box)}
  before{User.current = user}

  describe ".summary_of_analysis" do
    subject { obj.summary_of_analysis }
    let(:analysis_1){FactoryGirl.create(:analysis)}
    let(:item_1){FactoryGirl.create(:measurement_item)}
    let(:chemistry_1){FactoryGirl.create(:chemistry, :analysis_id => analysis_1.id, :measurement_item_id => item_1.id)}
    before {
      allow(obj.h).to receive(:can?).and_return(true)
      analysis_1.specimen = obj
      analysis_1.save
    }

    it { expect(subject).to include("<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#specimen-analyses-#{obj.id}\"><span class=\"badge\">1</span></a>") }
  end

  describe ".name_with_id" do
    subject{obj.name_with_id}
    it{expect(subject).to include(obj.name)}
    it{expect(subject).to include(obj.global_id)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span>")} 
  end

  describe ".path" do
    let(:me){"<span class=\"glyphicon glyphicon-cloud\"></span><span class=\"glyphicon glyphicon-\"></span>#{obj.name}"}
    subject{obj.path}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    context "box is nil" do
      before{obj.box = nil}
      it{expect(subject).to eq me} 
    end
    context "box is not nil" do
      before{obj.box = box}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")} 
      it{expect(subject).to include("<a href=\"/boxes/#{box.id}\">#{box.name}</a>")} 
      it{expect(subject).to include(me)} 
    end
  end

  describe ".primary_picture" do
    let(:attachment_file){ FactoryGirl.create(:attachment_file) }
    let(:picture) { obj.primary_picture(width: width, height: height) }
    let(:capybara) { Capybara.string(picture) }
    let(:body) { capybara.find("body") }
    let(:img) { body.find("img") }
    let(:width) { 250 }
    let(:height) { 250 }
    before { obj.attachment_files = [attachment_file] }
    it { expect(body).to have_css("img") }
    it { expect(img["src"]).to eq attachment_file.path }
    context "width rate greater than height rate" do
      let(:width) { 100 }
      it { expect(img["width"]).to eq width.to_s }
      it { expect(img["height"]).to be_blank }
    end
    context "width rate eq height rate" do
      it { expect(img["width"]).to eq width.to_s }
      it { expect(img["height"]).to be_blank }
    end
    context "width rate less than height rate" do
      let(:height) { 100 }
      it { expect(img["width"]).to be_blank }
      it { expect(img["height"]).to eq height.to_s }
    end
  end

  describe ".family_tree" do
    subject{obj.family_tree}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    it{expect(subject).to match("<div class=\"tree-node\" data-depth=\"1\">.*</div>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud glyphicon-active-color\"></span>")} 
    it{expect(subject).to match("<a href=\"/specimens/#{obj.id}\">.*</a>")}
    it{expect(subject).to include("<strong class=\"text-primary bg-primary\">#{obj.name}</strong>")} 
  end

  describe ".tree_node" do
    subject{obj.tree_node}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    let(:child){FactoryGirl.create(:specimen)}
    let(:analysis){FactoryGirl.create(:analysis)}
    let(:bib){FactoryGirl.create(:bib)}
    let(:attachment_file){FactoryGirl.create(:attachment_file)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span>")} 
    it{expect(subject).to include("#{obj.name}")} 
    before do
      obj.children << child
      obj.analyses << analysis
      obj.bibs << bib 
      obj.attachment_files << attachment_file 
    end
    it { expect(subject).to_not include("<span class=\"glyphicon glyphicon-cloud \"></span><span>#{obj.children.count}</span>") }
    it do
      expect(subject).to include(
        "<span class=\"glyphicon glyphicon-stats\"></span>"\
        + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
        + "<span class=\"badge\">#{obj.analyses.count}</span></a>"
      )
    end
    it do
      expect(subject).to include(
        "<span class=\"glyphicon glyphicon-book\"></span>"\
        + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
        + "<span class=\"badge\">#{obj.bibs.count}</span></a>"
      )
    end
    it do
      expect(subject).to include(
        "<span class=\"glyphicon glyphicon-file\"></span>"\
        + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
        + "<span class=\"badge\">#{obj.attachment_files.count}</span></a>"
      )
    end
    context "current" do
      subject{obj.tree_node(current: true)}
      it{expect(subject).to match("<strong class=\"text-primary bg-primary\">.*</strong>")}
    end
    context "not current" do
      subject{obj.tree_node(current: false)}
      it{expect(subject).not_to match("<strong>.*</strong>")} 
    end
    context "current_type" do
      context "in_list_include" do
        subject{ obj.tree_node(current_type: true, in_list_include: true) }
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-cloud glyphicon-active-color\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\">#{obj.children.count}</span></a>"
          )
        end
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-stats glyphicon-active-color\"></span><span>#{obj.analyses.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-book glyphicon-active-color\"></span><span>#{obj.bibs.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-file glyphicon-active-color\"></span><span>#{obj.attachment_files.count}</span>") }
      end
      context "not in_list_include" do
        subject{ obj.tree_node(current_type: true, in_list_include: false) }
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-cloud\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge\">#{obj.children.count}</span></a>"
          )
        end
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-stats\"></span><span>#{obj.analyses.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-book\"></span><span>#{obj.bibs.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-file\"></span><span>#{obj.attachment_files.count}</span>") }
      end
    end
    context "not current_type" do
      context "in_list_include" do
        subject{ obj.tree_node(current_type: false, in_list_include: true) }
        it{ expect(subject).to_not include("<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.children.count}</span>") }
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-stats glyphicon-active-color\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\">#{obj.analyses.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-book glyphicon-active-color\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\">#{obj.bibs.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-file glyphicon-active-color\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\">#{obj.attachment_files.count}</span></a>"
          )
        end
      end
      context "not in_list_include" do
        subject{ obj.tree_node(current_type: false, in_list_include: false) }
        it{ expect(subject).to_not include("<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.children.count}</span>") }
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-stats\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge\">#{obj.analyses.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-book\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge\">#{obj.bibs.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon glyphicon-file\"></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
            + "<span class=\"badge\">#{obj.attachment_files.count}</span></a>"
          )
        end
      end
    end
  end

  describe "children_count" do
    subject { obj.children_count }
    let(:icon) { "cloud" }
    let(:count) { obj.children.count }
    let(:child) { FactoryGirl.create(:specimen) }
    context "count zero" do
      before { obj.children.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.children << child }
      context "current_type" do
        context "in_list_include" do
          subject { obj.children_count(true, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.children_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon}\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
      context "not current_type" do
        subject { obj.children_count(false, false) }
        it { expect(subject).to be_blank }
      end
    end
  end

  describe "analyses_count" do
    subject { obj.analyses_count }
    let(:icon) { "stats" }
    let(:count) { obj.analyses.count }
    let(:analysis) { FactoryGirl.create(:analysis) }
    context "count zero" do
      before { obj.analyses.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.analyses << analysis }
      context "current_type" do
        context "in_list_include" do
          subject { obj.analyses_count(true, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.analyses_count(true, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.analyses_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.analyses_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon}\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
    end
  end

  describe "bibs_count" do
    subject { obj.bibs_count }
    let(:icon) { "book" }
    let(:count) { obj.bibs.count }
    let(:bib) { FactoryGirl.create(:bib) }
    context "count zero" do
      before { obj.bibs.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.bibs << bib }
      context "current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(true, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.bibs_count(true, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.bibs_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon}\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
    end
  end

  describe "files_count" do
    subject { obj.files_count }
    let(:icon) { "file" }
    let(:count) { obj.attachment_files.count }
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    context "count zero" do
      before { obj.attachment_files.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.attachment_files << attachment_file }
      context "current_type" do
        context "in_list_include" do
          subject { obj.files_count(true, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.files_count(true, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.files_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon} glyphicon-active-color\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.files_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon glyphicon-#{icon}\"></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{obj.record_property_id}\">"\
              + "<span class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
    end
  end

  describe ".to_tex" do
    subject{ obj.to_tex(alias_specimen) }
    before{ obj.children << child }
    let(:alias_specimen) { "specimen" }
    let(:child) { FactoryGirl.create(:specimen, name: child_name) }
    let(:child_name) { "child_name" }
    it{ expect(subject).to include(obj.name) }
    it{ expect(subject).to include(obj.global_id) }
    it{ expect(subject).to include(child.name) }
    it{ expect(subject).to include(child.physical_form.name) }
    it{ expect(subject).to include(child.quantity.to_s) }
    it{ expect(subject).to include(child.global_id) }
    it{ expect(subject).to include(alias_specimen) }
  end

  describe "status_name" do
    subject { obj.status_name }
    context "normal" do
      before { obj.update_attributes(quantity: 0.5, quantity_unit: "mg") }
      it { expect(subject).to eq("") }
    end
    context "undetermined quantity" do
      before { obj.update_attributes(quantity: "", quantity_unit: "") }
      it { expect(subject).to eq("Undetermined quantity") }
    end
    context "disappearance" do
      before { obj.update_attributes(quantity: "0", quantity_unit: "kg") }
      it { expect(subject).to eq("Disappearance") }
    end
    context "disposal" do
      before { obj.record_property.update_attributes(disposed: true) }
      it { expect(subject).to eq("Disposal") }
    end
    context "loss" do
      before { obj.record_property.update_attributes(lost: true) }
      it { expect(subject).to eq("Loss") }
    end
  end

  describe "status_icon" do
    subject { obj.status_icon }
    context "normal" do
      before { obj.update_attributes(quantity: 0.5, quantity_unit: "mg") }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-\"></span>") }
    end
    context "undetermined quantity" do
      before { obj.update_attributes(quantity: "", quantity_unit: "") }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-question-sign\"></span>") }
    end
    context "disappearance" do
      before { obj.update_attributes(quantity: "0", quantity_unit: "kg") }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-fire\"></span>") }
    end
    context "disposal" do
      before { obj.record_property.update_attributes(disposed: true) }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-trash\"></span>") }
    end
    context "loss" do
      before { obj.record_property.update_attributes(lost: true) }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-eye-close\"></span>") }
    end
  end
end
