require 'spec_helper'

describe BoxDecorator do
  let(:user){FactoryGirl.create(:user)}
  let(:obj){FactoryGirl.create(:box).decorate}
  before{User.current = user}

  describe ".name_with_id" do
    subject{obj.name_with_id}
    it{expect(subject).to include(obj.name)}
    it{expect(subject).to include(obj.global_id)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")}
  end

  describe ".primary_picture" do
    after { obj.primary_picture(width: width, height: height) }
    let(:width) { 250 }
    let(:height) { 250 }
    before { obj }
    context "attachment_files is null" do
      let(:attachment_file_1) { [] }
      it { expect(helper).not_to receive(:image_tag) }
    end
    context "attachment_files is not null" do
      let(:attachment_file_1) { FactoryGirl.create(:attachment_file, name: "att_1") }
      before { obj.attachment_files << attachment_file_1 }
      it { expect(helper).to receive(:image_tag).with(attachment_file_1.path, width: width, height: height) }
    end
  end

  describe ".family_tree" do
    subject{obj.family_tree}
    let(:child){FactoryGirl.create(:box)}
    before do
      allow(obj.h).to receive(:can?).and_return(true)
      obj.children << child
    end
    it{expect(subject).to match("<div class=\"tree-node\" data-depth=\"1\">.*</div>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")}
    it{expect(subject).to match("<a href=\"/boxes/#{obj.id}\">.*</a>")}
    it{expect(subject).to include("<strong>#{obj.name}</strong>")}
    it{expect(subject).to match("<div class=\"tree-node\" data-depth=\"2\">.*</div>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")}
    it{expect(subject).to match("<a href=\"/boxes/#{child.id}\">.*</a>")}
    it{expect(subject).to include("#{child.name}")}
  end

  describe ".tree_node" do
    subject{obj.tree_node}
    let(:stone){FactoryGirl.create(:stone)}
    let(:child){FactoryGirl.create(:box)}
    let(:analysis){FactoryGirl.create(:analysis)}
    let(:bib){FactoryGirl.create(:bib)}
    let(:attachment_file){FactoryGirl.create(:attachment_file)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")}
    it{expect(subject).to include("#{obj.name}")}
    before do
      allow(obj.h).to receive(:can?).and_return(true)
      stone.analyses << analysis
      obj.stones << stone
      obj.children << child
      obj.bibs << bib
      obj.attachment_files << attachment_file
    end
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.stones.count}</span>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span><span>#{obj.stones.count}</span>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-stats\"></span><span>#{obj.analyses.count}</span>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-book\"></span><span>#{obj.bibs.count}</span>")}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-file\"></span><span>#{obj.attachment_files.count}</span>")}
    context "current" do
      subject{obj.tree_node(true)}
      it{expect(subject).to match("<strong>.*</strong>")}
    end
    context "not current" do
      subject{obj.tree_node(false)}
      it{expect(subject).not_to match("<strong>.*</strong>")}
    end
  end

  describe "stones_count" do
    subject{obj.stones_count}
    let(:icon){"cloud"}
    let(:count){obj.stones.count}
    context "count zero" do
      before{obj.stones.clear}
      it{expect(subject).to be_blank}
    end
    context "count zero" do
      let(:stone){FactoryGirl.create(:stone)}
      before{obj.stones << stone}
      it{expect(subject).to include("<span>#{count}</span>")}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-#{icon}\"></span>")}
    end
  end

  describe "boxes_count" do
    subject{obj.boxes_count}
    let(:icon){"folder-close"}
    let(:count){obj.children.count}
    context "count zero" do
      before{obj.children.clear}
      it{expect(subject).to be_blank}
    end
    context "count not zero" do
      let(:child){FactoryGirl.create(:box)}
      before{obj.children << child}
      it{expect(subject).to include("<span>#{count}</span>")}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-#{icon}\"></span>")}
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
      let(:stone){FactoryGirl.create(:stone)}
      let(:analysis){FactoryGirl.create(:analysis)}
      before{stone.analyses  << analysis}
      before{obj.stones << stone}
      it{expect(subject).to include("<span>#{count}</span>")}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-#{icon}\"></span>")}
    end
  end

  describe "bibs_count" do
    subject{obj.bibs_count}
    let(:icon){"book"}
    let(:count){obj.bibs.count}
    context "count zero" do
      before{obj.bibs.clear}
      it{expect(subject).to be_blank}
    end
    context "count not zero" do
      let(:bib){FactoryGirl.create(:bib)}
      before{obj.bibs << bib}
      it{expect(subject).to include("<span>#{count}</span>")}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-#{icon}\"></span>")}
    end
  end

  describe "files_count" do
    subject{obj.files_count}
    let(:icon){"file"}
    let(:count){obj.attachment_files.count}
    context "count zero" do
      before{obj.attachment_files.clear}
      it{expect(subject).to be_blank}
    end
    context "count zero" do
      let(:attachment_file){FactoryGirl.create(:attachment_file)}
      before{obj.attachment_files << attachment_file}
      it{expect(subject).to include("<span>#{count}</span>")}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-#{icon}\"></span>")}
    end
  end

  describe ".boxed_stones" do
    subject{obj.boxed_stones}
    it{expect(subject).to eq(Stone.includes(:record_property, :user, :group, :physical_form).where(box_id: obj.id))} 
  end

  describe ".boxed_boxes" do
    subject{obj.boxed_boxes}
    it{expect(subject).to eq(Box.includes(:record_property, :user, :group).where(parent_id: obj.id))} 
  end

  describe ".to_tex" do
    subject { obj.to_tex }
    let(:stone) { FactoryGirl.create(:stone, name: "name_1", box_id: obj.id) }
    let(:time_now) { Time.now.to_date }
    before { obj.stones << stone }
    it { expect(subject).to eq "%------------\nThe sample names and ID of each mounted materials are listed in Table \\ref{mount:materials}.\n%------------\n\\begin{footnotesize}\n\\begin{table}\n\\caption{Stones mounted on #{obj.name} (#{obj.global_id}) as of #{time_now}.}\n\\begin{center}\n\\begin{tabular}{lll}\n\\hline\nstone name\t&\tID\t&\tremark\\\\\n\\hline\nname_1\t&\t#{stone.global_id}\t&\t\\\\\n\\hline\n\\end{tabular}\n\\end{center}\n\\label{mount:materials}\n\\end{table}\n\\end{footnotesize}\n%------------" }
  end

end
