require 'spec_helper'

describe Path do
  let(:user){ FactoryGirl.create(:user, :username => "test-1", :email => "test-1@example.com")}

	before do
    allow(User).to receive(:current).and_return(user)
	end
	describe "contents_of" do
    let(:box){ FactoryGirl.create(:box, :name => "box-1", :parent_id => shelf.id) }
    let(:shelf){ FactoryGirl.create(:box, :name => "D", :parent_id => room.id) }
    let(:shelf_b){ FactoryGirl.create(:box, :name => "A", :parent_id => room_b.id) }
    let(:room){ FactoryGirl.create(:box, :name => "127", :parent_id => building.id) }
    let(:room_b){ FactoryGirl.create(:box, :name => "126", :parent_id => building.id) }
    let(:building){ FactoryGirl.create(:box, :name => "main") }

    before do
      box
    end
    subject { Path.contents_of(room) }
    it { expect(subject.map(&:datum)).to include(box) }
    it { expect(subject.map(&:datum)).to include(shelf) }
    it { expect(subject.map(&:datum)).not_to include(shelf_b) }
	end


  describe "add_histroy" do
    let(:time_now){ Time.now }
    let(:time_1_day_ago){ time_now.days_ago(1) }
    let(:time_2_days_ago){ time_now.days_ago(2) }
    let(:time_3_days_ago){ time_now.days_ago(3) }
    let(:box){ FactoryGirl.create(:box, :name => "box-1", :parent_id => shelf_floor_1.id) }
    let(:shelf_floor_1){ FactoryGirl.create(:box, :name => "1", :parent_id => shelf.id) }
    let(:shelf_floor_2){ FactoryGirl.create(:box, :name => "2", :parent_id => shelf.id) }
    let(:shelf_floor_3){ FactoryGirl.create(:box, :name => "3", :parent_id => shelf.id) }
    let(:shelf_floor_4){ FactoryGirl.create(:box, :name => "4", :parent_id => shelf.id) }
    let(:shelf){ FactoryGirl.create(:box, :name => "D", :parent_id => room.id) }
    let(:room){ FactoryGirl.create(:box, :name => "127") }
	  let(:ids){ shelf_floor_3.ancestors.map(&:id).push(shelf_floor_3.id) }
    before do
      shelf
      shelf_floor_1
      shelf_floor_2
      shelf_floor_3
      shelf_floor_4
      box
      box.add_histroy(time_1_day_ago, ids)
      # box.paths.each do |path|
      #   puts "#{path.id} #{path.brought_in_at} #{path.brought_out_at} #{path.to_posix_style} "
      # end
    end
    it { expect(box.paths.map(&:ids)).to include(ids) }
  end

  describe ".cont_at(date)"do
    subject { Path.cont_at(date) }
    let!(:specimen) { FactoryGirl.create(:specimen) }
   
    context "date指定あり" do
      let(:date) { "21151117" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at, :checked_at)
        expect(subject[0].attributes).to eql sample[0].attributes
      end
    end
    context "date指定なし" do
      let(:date) { "" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at, :checked_at)
        expect(subject[0].attributes).to eql sample[0].attributes
      end
    end
    context "該当なし" do
      let(:date) { "20141111" }
      it { expect(subject).to eq [] }
    end
  end


  describe ".integ", :current => true do
    subject { Path.integ(box, src_date, dst_date) }
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:box) { specimen.box }
    let(:dst_date) { "2005-11-19" }
    let(:src_date) { "2005-11-16" }
    let(:path) { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [box.id], brought_in_at: brought_in_at, brought_out_at: brought_out_at) } 
    let(:paths) { Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at, :checked_at) }
    let(:brought_out_at) { "20051120" }
    let(:brought_in_at) { "20051117" }
    before do
      path
      paths
    end
    context "brought_in_at after src_date and brought-out_at after dst_date" do
      it { expect(subject[0].attributes).to include paths[0].attributes }
      it { expect(subject[0].attributes["sign"]).to eq "+" }
    end
    context "brought_in_at before src_date and brought-out_at after dst_date" do
      let(:brought_out_at) { "20051120" }
      let(:brought_in_at) { "20051115" }
      it { expect(subject[1].attributes).to include paths[1].attributes }
      it { expect(subject[1].attributes["sign"]).to eq "" }
    end
    context "brought-out_at before dst_date" do
      let(:brought_out_at) { "20051118" }
      it { expect(subject[1].attributes).to include paths[1].attributes }
      it { expect(subject[1].attributes["sign"]).to eq "-"}
    end

  end
  
  describe ".diff(box, src_date, dst_date)" do
    subject { Path.diff(box, src_date, dst_date) }
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:box) { specimen.box }
    let(:src_date) { "20051117" }
    let(:dst_date) { "20051119" }
    let(:path) { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [box.id], brought_in_at: brought_in_at, brought_out_at: brought_out_at) } 
    let(:paths) { Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at) }

    context "brought-in before src_date" do
      let(:brought_in_at){ "20051114" }
      before do
        path
      end

      context "brought-out before src_date" do
        let(:brought_out_at){ "20051115" }
        it "returns empty" do
          paths
          expect(subject).to eq []      
        end
      end

      context "brought-out before dst_date", :current => true do
        let(:brought_out_at){ "20051118" }
        it "returns path" do
          paths
          expect(subject[0].attributes).to include paths[1].attributes
          expect(subject[0].attributes["sign"]).to eq "-"
          expect(subject[0].sign).to eq "-"
          expect(subject[0].checked_at).to be_nil
        end
      end

      context "brought-out after dst_date" do
        let(:brought_out_at){ "20051120" }
        it "returns empty" do
          paths
          expect(subject).to eq []      
        end
      end

      context "brought-out nil" do
        let(:brought_out_at){ nil }
        it "returns empty" do
          paths
          expect(subject).to eq []      
        end
      end
    end

    context "brought-in after src_date" do
      let(:brought_in_at){ "20051118" }
      before do
        path
      end

      context "brought-out before dst_date" do
        let(:brought_out_at){ "20051118" }
        it "returns empty" do
          paths
          expect(subject).to eq []      
        end
      end

      context "brought-out after dst_date" do
        let(:brought_out_at){ "20051120" }
        it "returns +path" do
          paths
          expect(subject[0].attributes).to include paths[1].attributes
          expect(subject[0].attributes["sign"]).to eq "+"
        end
      end

      context "brought-out nil" do
        let(:brought_out_at){ nil }
        it "returns +path" do
          paths
          expect(subject[0].attributes).to include paths[1].attributes
          expect(subject[0].attributes["sign"]).to eq "+"
        end
      end
    end

    context "brought-in during src_date and dst_date" do
      let(:brought_in_at){ "20051118" }
      let(:brought_out_at){ nil }
      before do
        path
      end
      it "returns path" do
        paths
        expect(subject[0].attributes).to include paths[1].attributes
        expect(subject[0].attributes["sign"]).to eq "+"
      end
    end

    context "brought-in after dst_date" do
      let(:brought_in_at){ "20051121" }
      let(:brought_out_at){ nil }
      before do
        path
      end
      it "returns []" do
        paths
        expect(subject).to eq []        
      end
    end

    context "brought-in after dst_date" do
      let(:brought_in_at){ "20051121" }
      before do
        path
      end

      context "brought-out after dst_date" do
        let(:brought_out_at){ "20051122" }
        it "returns empty" do
          paths
          expect(subject).to eq []      
        end
      end

      context "brought-out nil" do
        let(:brought_out_at){ nil }
        it "returns empty" do
          paths
          expect(subject).to eq []      
        end
      end

    end
    context "該当あり(sign+)" do
      before { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [box.id], brought_in_at: "20151118", brought_out_at: "20151120") }
      let(:src_date) { "20151117" }
      let(:dst_date) { "20151119" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at)[1]
        expect(subject[0].attributes).to include sample.attributes
        expect(subject[0].attributes["sign"]).to eq "+"
      end
    end
    context "該当あり(sign-)" do
      before do
        FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [box.id], brought_in_at: "2005-11-20 01:40:12", brought_out_at: "2005-11-23 01:43:12")
      end
      let(:src_date) { "20051121" }
      let(:dst_date) { "20051124" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at)
        expect(subject[0].attributes).to include sample[1].attributes
        expect(subject[0].attributes["sign"]).to eq "-"
      end
    end
    context "該当なし" do
      let(:src_date) { "20051117" }
      let(:dst_date) { "20051119" }
      it { expect(subject).to eq [] }
    end
  end

  describe "change" do
    subject { Path.change(box, src_date, dst_date) }
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:box) { specimen.box }
    let(:brought_in_at) { Date.new(2015, 12, 2) }
    let(:brought_out_at) { Date.new(2015, 12, 3) }
    before { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [box.id], brought_in_at: brought_in_at, brought_out_at: brought_out_at) }
    context "brought_in_atが期間内" do
      let(:src_date) { Time.new(2015, 12, 2).beginning_of_day }
      let(:dst_date) { Time.new(2015, 12, 2).end_of_day }
      it { expect(subject).to be_present }
    end
    context "brought_out_atが期間内" do
      let(:src_date) { Time.new(2015, 12, 3).beginning_of_day }
      let(:dst_date) { Time.new(2015, 12, 3).end_of_day }
      it { expect(subject).to be_present }
    end
    context "どちらも期間外" do
      let(:src_date) { Time.new(2015, 12, 4).beginning_of_day }
      let(:dst_date) { Time.new(2015, 12, 4).end_of_day }
      it { expect(subject).to be_blank }
    end
  end
  
  describe "each"do
    let(:specimen) { FactoryGirl.create(:specimen) }
    context "idsがpresent" do
      let(:path) { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [specimen.box.id]) }
      it "result" do
        proc = Proc.new do |sample|
          sample
        end
        expect(path.each(&proc)).to eq specimen
      end
      it "yieldが2回呼ばれる" do
        count = 0
        proc = Proc.new do |sample|
          sample
          count += 1
        end
        expect(path.each(&proc)).to eq 2
      end
    end
    context "idsがblank" do
      let(:path) { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: nil) }
      it "result" do
        count = 0
        proc = Proc.new do |sample|
          count += 1
          sample
        end
        expect(path.each(&proc)).to eq specimen
      end
      it "yieldが1回呼ばれる" do
        count = 0
        proc = Proc.new do |sample|
          sample
          count += 1
        end
        expect(path.each(&proc)).to eq 1
      end
    end
  end
  
  describe "boxes"do
    let(:specimen) { FactoryGirl.create(:specimen) }
    context "idsがpresent" do
      let(:path) { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: [specimen.box.id]) }
      it { expect(path.boxes).to eq [specimen.box] }
    end
    context "idsがblank" do
      let(:path) { FactoryGirl.create(:path_specimen, datum_id: specimen.id, ids: nil) }
      it { expect(path.boxes).to eq [] }
    end
  end
  
  describe ".ransackable_scopes(auth_object = nil)"do
    subject { Path.ransackable_scopes(auth_object = nil) }
    it { expect(subject).to eq [:exists_at] }
  end
end
