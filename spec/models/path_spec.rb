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
		# 	puts "#{path.id} #{path.brought_in_at} #{path.brought_out_at} #{path.to_posix_style} "
		# end
	   end
	   it {
	   	expect(box.paths.map(&:ids)).to include(ids)
	   }
  end
end