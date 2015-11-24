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
    let(:stone) { FactoryGirl.create(:stone) }
    before do
      FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [stone.box.id])
    end
    context "date指定あり" do
      let(:date) { "20151117" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at).last
        expect(subject[0].attributes).to eql sample.attributes
      end
    end
    context "date指定なし" do
      let(:date) { "" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at).first
        expect(subject[0].attributes).to eql sample.attributes
      end
    end
    context "該当なし" do
      let(:date) { "20141111" }
      it { expect(subject).to eq [] }
    end
  end
  
  describe ".diff(box, src_date, dst_date)"do
    subject { Path.diff(box, src_date, dst_date) }
    let(:stone) { FactoryGirl.create(:stone) }
    let(:box) { stone.box }
    context "該当あり(sign+)" do
      before do
        FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [box.id], brought_in_at: "20151118", brought_out_at: "20151118")
        FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [box.id], brought_in_at: "20151118", brought_out_at: nil)
      end
      let(:src_date) { "20151117" }
      let(:dst_date) { "20151118" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at)[1]
        expect(subject[0].attributes).to include sample.attributes
        expect(subject[0].attributes["sign"]).to eq "+"
      end
    end
    context "該当あり(sign-)" do
      before do
        FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [box.id], brought_in_at: "2005-11-20 01:40:12", brought_out_at: "2005-11-20 01:43:12")
        FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [box.id, box.id+1], brought_in_at: "2005-11-20 01:43:12", brought_out_at: nil)
      end
      let(:src_date) { "20051120" }
      let(:dst_date) { "20051122" }
      it "result" do
        sample = Path.select(:datum_id, :datum_type, :ids, :brought_in_at, :brought_out_at)[1]
        expect(subject[0].attributes).to include sample.attributes
        expect(subject[0].attributes["sign"]).to eq "-"
      end
    end
    context "該当なし" do
      let(:src_date) { "20151112" }
      let(:dst_date) { "20151113" }
      it { expect(subject).to eq [] }
    end
  end
  
  describe "each"do
    let(:stone) { FactoryGirl.create(:stone) }
    context "idsがpresent" do
      let(:path) { FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [stone.box.id]) }
      it "result" do
        proc = Proc.new do |sample|
          sample
        end
        expect(path.each(&proc)).to eq stone
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
      let(:path) { FactoryGirl.create(:path_stone, datum_id: stone.id, ids: nil) }
      it "result" do
        count = 0
        proc = Proc.new do |sample|
          count += 1
          sample
        end
        expect(path.each(&proc)).to eq stone
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
    let(:stone) { FactoryGirl.create(:stone) }
    context "idsがpresent" do
      let(:path) { FactoryGirl.create(:path_stone, datum_id: stone.id, ids: [stone.box.id]) }
      it { expect(path.boxes).to eq [stone.box] }
    end
    context "idsがblank" do
      let(:path) { FactoryGirl.create(:path_stone, datum_id: stone.id, ids: nil) }
      it { expect(path.boxes).to eq [] }
    end
  end
  
  describe ".ransackable_scopes(auth_object = nil)"do
    subject { Path.ransackable_scopes(auth_object = nil) }
    it { expect(subject).to eq [:exists_at] }
  end
end
