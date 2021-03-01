require 'spec_helper'

describe SearchColumn do
  describe "scope" do
    describe "default_scope" do
      let!(:column1) { FactoryBot.create(:search_column, display_order: 2) }
      let!(:column2) { FactoryBot.create(:search_column, display_order: 1) }
      subject { SearchColumn.all }
      it { expect(subject).to eq [column2, column1] }
    end

    describe "model_is" do
      let!(:column1) { FactoryBot.create(:search_column, datum_type: "Specimen") }
      let!(:column2) { FactoryBot.create(:search_column, datum_type: "Box") }
      subject { SearchColumn.model_is(Specimen) }
      it { expect(subject).to match_array [column1] }
    end

    describe "user_is" do
      let!(:user1) { FactoryBot.create(:user_foo) }
      let!(:user2) { FactoryBot.create(:user_baa) }
      let!(:column1) { FactoryBot.create(:search_column, user: user1) }
      let!(:column2) { FactoryBot.create(:search_column, user: user2) }
      subject { SearchColumn.user_is(user1) }
      it { expect(subject).to match_array [column1] }
    end

    describe "master" do
      let!(:user) { FactoryBot.create(:user_foo) }
      let!(:column1) { FactoryBot.create(:search_column, user_id: user.id) }
      let!(:column2) { FactoryBot.create(:search_column, user_id: 0) }
      subject { SearchColumn.master }
      it { expect(subject).to match_array [column2] }
    end

    describe "display_expand" do
      let!(:column1) { FactoryBot.create(:search_column, display_type: 0) }
      let!(:column2) { FactoryBot.create(:search_column, display_type: 1) }
      let!(:column3) { FactoryBot.create(:search_column, display_type: 2) }
      subject { SearchColumn.display_expand }
      it { expect(subject).to match_array [column2, column3] }
    end

    describe "display_always" do
      let!(:column1) { FactoryBot.create(:search_column, display_type: 0) }
      let!(:column2) { FactoryBot.create(:search_column, display_type: 1) }
      let!(:column3) { FactoryBot.create(:search_column, display_type: 2) }
      subject { SearchColumn.display_always }
      it { expect(subject).to match_array [column3] }
    end
  end

  describe "class methods" do
    describe "update_display" do
      let!(:column1) { FactoryBot.create(:search_column, user_id: user_id, display_order: 1, display_type: 0) }
      let!(:column2) { FactoryBot.create(:search_column, user_id: user_id, display_order: 2, display_type: 1) }
      let!(:column3) { FactoryBot.create(:search_column, user_id: user_id, display_order: 3, display_type: 2) }
      let!(:column4) { FactoryBot.create(:search_column, user_id: 0, display_order: 4, display_type: 0) }
      let(:display_type_hash) do
        { column3.id => 0, column2.id => 2, column1.id => 1 }
      end
      let(:user_id) { 1 }
      subject { SearchColumn.update_display(display_type_hash, user_id) }
      it { expect{ subject }.to change{ column1.reload.display_order }.from(1).to(3) }
      it { expect{ subject }.to_not change{ column2.reload.display_order } }
      it { expect{ subject }.to change{ column3.reload.display_order }.from(3).to(1) }
      it { expect{ subject }.to_not change{ column4.reload.display_order } }
      it { expect{ subject }.to change{ column1.reload.display_type }.from(0).to(1) }
      it { expect{ subject }.to change{ column2.reload.display_type }.from(1).to(2) }
      it { expect{ subject }.to change{ column3.reload.display_type }.from(2).to(0) }
      it { expect{ subject }.to_not change{ column4.reload.display_type } }
    end
  end

  describe "instance methods" do
    describe "none?" do
      let!(:column) { FactoryBot.create(:search_column, display_type: display_type) }
      subject { column.none? }
      context "display_type is none" do
        let(:display_type) { 0 }
        it { expect(subject).to eq true }
      end
      context "display_type is expand" do
        let(:display_type) { 1 }
        it { expect(subject).to eq false }
      end
      context "display_type is always" do
        let(:display_type) { 2 }
        it { expect(subject).to eq false }
      end
    end

    describe "expand?" do
      let!(:column) { FactoryBot.create(:search_column, display_type: display_type) }
      subject { column.expand? }
      context "display_type is none" do
        let(:display_type) { 0 }
        it { expect(subject).to eq false }
      end
      context "display_type is expand" do
        let(:display_type) { 1 }
        it { expect(subject).to eq true }
      end
      context "display_type is always" do
        let(:display_type) { 2 }
        it { expect(subject).to eq false }
      end
    end

    describe "always?" do
      let!(:column) { FactoryBot.create(:search_column, display_type: display_type) }
      subject { column.always? }
      context "display_type is none" do
        let(:display_type) { 0 }
        it { expect(subject).to eq false }
      end
      context "display_type is expand" do
        let(:display_type) { 1 }
        it { expect(subject).to eq false }
      end
      context "display_type is always" do
        let(:display_type) { 2 }
        it { expect(subject).to eq true }
      end
    end
  end
end
