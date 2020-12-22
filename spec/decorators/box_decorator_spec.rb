require 'spec_helper'

describe BoxDecorator do
  let(:user){FactoryGirl.create(:user)}
  let(:obj){FactoryGirl.create(:box).decorate}
  before{User.current = user}

  describe "icon" do
    subject { BoxDecorator.icon }
    it { expect(subject).to eq ("<span class=\"glyphicon glyphicon-folder-close\"></span>") }
    context "in_list_include is true" do
      subject { BoxDecorator.icon(true) }
      it { expect(subject).to eq ("<span class=\"glyphicon glyphicon-folder-open\"></span>") }
    end
    context "in_list_include is false" do
      subject { BoxDecorator.icon(false) }
      it { expect(subject).to eq ("<span class=\"glyphicon glyphicon-folder-close\"></span>") }
    end
  end

  describe ".to_json", :current => true do
    subject{obj.to_json}
    it{ expect(subject).to include "global_id" }
  end

  describe ".name_with_id" do
    subject{obj.name_with_id}
    it{expect(subject).to include(obj.name)}
    it{expect(subject).to include(obj.global_id)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")}
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
    let(:child){FactoryGirl.create(:box)}
    let(:specimen){FactoryGirl.create(:specimen)}
    before do
      allow(obj.h).to receive(:can?).and_return(true)
      obj.children << child
    end
    it{expect(subject).to match("<div class=\"tree-node\" data-depth=\"1\">.*</div>")}
    it{expect(subject).to include("<span class=\"box glyphicon-active-color\"><span class=\"glyphicon glyphicon-folder-open\"></span></span>")}
    it{expect(subject).to match("<a href=\"/boxes/#{obj.id}\">.*</a>")}
    it{expect(subject).to include("<strong class=\"text-primary bg-primary\">#{obj.name}</strong>")}
    it{expect(subject).to match("<div class=\"tree-node\" data-depth=\"2\">.*</div>")}
    it{expect(subject).to include("<span class=\"box\"><span class=\"glyphicon glyphicon-folder-close\"></span></span>")}
    it{expect(subject).to match("<a href=\"/boxes/#{child.id}\">.*</a>")}
    it{expect(subject).to include("#{child.name}")}
    context "box linked specimen" do
      before { obj.specimens << specimen }
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span>")}
      it{expect(subject).to match("<a href=\"/specimens/#{specimen.id}\">.*</a>")}
      it{expect(subject).to include("#{specimen.name}")}
    end
    context "box not link specimen" do
      it{expect(subject).not_to include("#{specimen.name}")}
    end
  end

  describe "tree_nodes" do
    let(:box) { FactoryGirl.create(:box, name: "test_1") }
    let(:specimen) { FactoryGirl.create(:specimen, name: "test_2") }
    let(:bib) { FactoryGirl.create(:bib, name: "test_3") }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, name: "test_4", data_file_name: "test_4.jpg") }
    let(:analysis) { FactoryGirl.create(:analysis, name: "test_5") }
    before do
      sign_in user
      obj.children << box
      obj.specimens << specimen
      obj.bibs << bib
      obj.attachment_files << attachment_file
    end
    subject { obj.tree_nodes(klass, 10) }
    context "klass is Box" do
      let(:klass) { Box }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"box\">"\
          + "<span class=\"glyphicon glyphicon-folder-close\"></span>"\
          + "</span>"\
          + "<a href=\"/boxes/#{box.id}\">test_1</a>"\
          + "<span class=\"\" title=\"status:unknown\"><span class=\"glyphicon glyphicon-question-sign\"></span></span>"\
          + "</div>"\
          + "<div class=\"collapse\" id=\"tree-Box-#{box.record_property_id}\"></div>"\
          + "<div class=\"collapse\" id=\"tree-Specimen-#{box.record_property_id}\"></div>"\
          + "<div class=\"collapse\" id=\"tree-Bib-#{box.record_property_id}\"></div>"\
          + "<div class=\"collapse\" id=\"tree-AttachmentFile-#{box.record_property_id}\"></div>"\
          + "</div>"
        )
      end
    end
    context "klass is Specimen" do
      let(:klass) { Specimen }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"\">"\
          + "<span class=\"glyphicon glyphicon-cloud\"></span>"\
          + "</span>"\
          + "<a href=\"/specimens/#{specimen.id}\">test_2</a>"\
          + "<span class=\"\" title=\"status:\">"\
          + "<span class=\"glyphicon glyphicon-\"></span>"\
          + "</span>"\
          + "</div>"\
          + "<div class=\"collapse\" id=\"tree-Analysis-#{specimen.record_property_id}\"></div>"\
          + "<div class=\"collapse\" id=\"tree-Bib-#{specimen.record_property_id}\"></div>"\
          + "<div class=\"collapse\" id=\"tree-AttachmentFile-#{specimen.record_property_id}\"></div>"\
          + "</div>"
        )
      end
    end
    context "klass is Bib" do
      let(:klass) { Bib }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"glyphicon glyphicon-book\"></span>"\
          + "<a href=\"/bibs/#{bib.id}\">test_3</a>"\
          + "</div>"\
          + "</div>"
        )
      end
    end
    context "klass is AttachmentFile" do
      let(:klass) { AttachmentFile }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"glyphicon glyphicon-file\"></span>"\
          + "<a href=\"/attachment_files/#{attachment_file.id}\">test_4.jpg</a>"\
          + "</div>"\
          + "</div>"
        )
      end
    end
    context "other klass" do
      let(:klass) { Analysis }
      it { expect(subject).to eq("") }
    end
  end

  describe ".tree_node", :current => true do
    subject{obj.tree_node}
    let(:specimen){FactoryGirl.create(:specimen)}
    let(:child){FactoryGirl.create(:box)}
    let(:analysis){FactoryGirl.create(:analysis)}
    let(:bib){FactoryGirl.create(:bib)}
    let(:attachment_file){FactoryGirl.create(:attachment_file)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")}
    it{expect(subject).to include("#{obj.name}")}
    before do
      allow(obj.h).to receive(:can?).and_return(true)
      specimen.analyses << analysis
      obj.specimens << specimen
      obj.children << child
      obj.bibs << bib
      obj.attachment_files << attachment_file
    end
    it { expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span><span>#{obj.children.count}</span>") }
    it { expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.specimens.count}</span>") }
    it { expect(subject).to_not include("<span class=\"glyphicon glyphicon-stats\"></span><span>#{obj.analyses.count}</span>") }
    it { expect(subject).to include("<span class=\"glyphicon glyphicon-book\"></span><span>#{obj.bibs.count}</span>") }
    it { expect(subject).to include("<span class=\"glyphicon glyphicon-file\"></span><span>#{obj.attachment_files.count}</span>") }
    context "current" do
      subject { obj.tree_node(current: true) }
      it { expect(subject).to match("<strong class=\"text-primary bg-primary\">.*</strong>") }
    end
    context "not current" do
      subject { obj.tree_node(current: false) }
      it { expect(subject).not_to match("<strong>.*</strong>") }
    end
    context "current_type" do
      context "in_list_include" do
        subject { obj.tree_node(current_type: true, in_list_include: true) }
        it do
          expect(subject).to include(
            "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-folder-close\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Box-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\" data-klass=\"Box\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.children.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-cloud\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Specimen-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\" data-klass=\"Specimen\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.specimens.count}</span></a>"
          )
        end
      end
      context "not in_list_include" do
        subject { obj.tree_node(current_type: true, in_list_include: false) }
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"glyphicon glyphicon-folder-close\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Box-#{obj.record_property_id}\">"\
            + "<span class=\"badge\" data-klass=\"Box\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.children.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"glyphicon glyphicon-cloud\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Specimen-#{obj.record_property_id}\">"\
            + "<span class=\"badge\" data-klass=\"Specimen\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.specimens.count}</span></a>"
          )
        end
      end
    end
    context "not current_type" do
      subject{ obj.tree_node(current_type: false) }
      it{expect(subject).to include(
        "<span class=\"glyphicon glyphicon-folder-close\"></span><span>#{obj.children.count}</span>"
      )}
      it{expect(subject).to include(
        "<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.specimens.count}</span>"
      )}
    end
  end

  describe "specimens_count" do
    subject{obj.specimens_count}
    let(:icon){"cloud"}
    let(:klass) { "Specimen" }
    let(:count){obj.specimens.count}
    let(:specimen){FactoryGirl.create(:specimen)}
    context "count zero" do
      before{obj.specimens.clear}
      it{expect(subject).to be_blank}
    end
    context "count not zero" do
      before{obj.specimens << specimen}
      context "current_type" do
        context "in_list_include" do
          subject { obj.specimens_count(true, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.specimens_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.specimens_count(false, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.specimens_count(false, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
    end
  end

  describe "boxes_count" do
    subject{obj.boxes_count}
    let(:icon){"folder-close"}
    let(:klass){"Box"}
    let(:count){obj.children.count}
    let(:child){FactoryGirl.create(:box)}
    context "count zero" do
      before{obj.children.clear}
      it{expect(subject).to be_blank}
    end
    context "count not zero" do
      before{obj.children << child}
      context "current_type" do
        context "in_list_include" do
          subject { obj.boxes_count(true, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.boxes_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.boxes_count(false, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.boxes_count(false, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
    end
  end

  describe "analyses_count" do
    subject{obj.analyses_count}
    let(:icon){"stats"}
    let(:count){obj.analyses.count}
    context "count zero" do
      before{obj.analyses.clear}
      it{expect(subject).to be_blank}
    end
    context "count not zero" do
      let(:specimen){FactoryGirl.create(:specimen)}
      let(:analysis){FactoryGirl.create(:analysis)}
      before{specimen.analyses  << analysis}
      before{obj.specimens << specimen}
      it{expect(subject).to include("<span>#{count}</span>")}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-#{icon}\"></span>")}
    end
  end

  describe "bibs_count" do
    subject { obj.bibs_count }
    let(:icon) { "book" }
    let(:klass) { "Bib" }
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
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.bibs_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(false, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.bibs_count(false, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
    end
  end

  describe "files_count" do
    subject { obj.files_count }
    let(:icon) { "file" }
    let(:klass) { "AttachmentFile" }
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
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.files_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.files_count(false, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.files_count(false, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
    end
  end

  describe ".boxed_specimens" do
    subject{obj.boxed_specimens}
    it{expect(subject).to eq(Specimen.includes(:record_property, :user, :group, :physical_form).where(box_id: obj.id))} 
  end

  describe ".boxed_boxes" do
    subject{obj.boxed_boxes}
    it{expect(subject).to eq(Box.includes(:record_property, :user, :group).where(parent_id: obj.id))} 
  end

  describe ".to_tex" do
    subject { obj.to_tex(alias_specimen) }
    before { obj.specimens << specimen }
    let(:alias_specimen) { "specimen" }
    let(:specimen) { FactoryGirl.create(:specimen, name: "name_1", box_id: obj.id) }
    let(:time_now) { Time.now.to_date }
    it { expect(subject).to eq "%------------\nThe sample names and ID of each mounted materials are listed in Table \\ref{mount:materials}.\n%------------\n\\begin{footnotesize}\n\\begin{table}\n\\caption{#{alias_specimen.pluralize.capitalize} mounted on #{obj.name} (#{obj.global_id}) as of #{time_now}.}\n\\begin{center}\n\\begin{tabular}{lll}\n\\hline\n#{alias_specimen} name\t&\tID\t&\tremark\\\\\n\\hline\nname_1\s&\s#{specimen.global_id}\s& #{specimen.description}\\\\\n\\hline\n\\end{tabular}\n\\end{center}\n\\label{mount:materials}\n\\end{table}\n\\end{footnotesize}\n%------------" }
  end

end
