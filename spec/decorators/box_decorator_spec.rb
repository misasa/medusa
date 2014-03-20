require 'spec_helper'

describe BoxDecorator do
  
  describe ".name_with_id" do
  end
  
  describe ".primary_picture" do
    after { box.primary_picture(width: width, height: height) }
    let(:box) { FactoryGirl.create(:box).decorate }
    let(:width) { 250 }
    let(:height) { 250 }
    before { box }
    context "attachment_files is null" do
      let(:attachment_file_1) { [] }
      it { expect(helper).not_to receive(:image_tag) }
    end
    context "attachment_files is not null" do
      let(:attachment_file_1) { FactoryGirl.create(:attachment_file, name: "att_1") }
      before { box.attachment_files << attachment_file_1 }
      it { expect(helper).to receive(:image_tag).with(attachment_file_1.path, width: width, height: height) }
    end
  end
  
  describe ".family_tree" do
  end
  
  describe ".tree_node" do
  end
  
  describe ".boxed_stones" do
  end
  
  describe ".boxed_boxes" do
  end
  
  describe ".to_tex" do
    subject { box.to_tex }
    let(:box) { FactoryGirl.create(:box).decorate }
    let(:stone) { FactoryGirl.create(:stone, name: "name_1", box_id: box.id) }
    let(:time_now) { Time.now.to_date }
    before do
      box
      stone
    end
    it { expect(subject).to eq "%------------\nThe sample names and ID of each mounted materials are listed in Table \\ref{mount:materials}.\n%------------\n\\begin{footnotesize}\n\\begin{table}\n\\caption{Stones mounted on box_1 (#{box.global_id}) as of #{time_now}.}\n\\begin{center}\n\\begin{tabular}{lll}\n\\hline\nstone name\t&\tID\t&\tremark\\\\\n\\hline\nname_1\t&\t#{stone.global_id}\t&\t\\\\\n\\hline\n\\end{tabular}\n\\end{center}\n\\label{mount:materials}\n\\end{table}\n\\end{footnotesize}\n%------------" }
  end
  
end