require 'spec_helper'

describe "group master" do
  before do
    login login_user
    create_data
    visit groups_path
  end
  let(:login_user) { FactoryGirl.create(:user) }
  let(:create_data) {}
  
  describe "list screen" do
    it "correctly display the label" do
      expect(page).to have_content("name")
      expect(page).to have_content("updated-at")
      expect(page).to have_content("created-at")
    end
    
    it "label linked display" do
      expect(page).to have_link("name")
      expect(page).to have_link("updated-at")
      expect(page).to have_link("created-at")
    end
    
    it "other field display" do
      #name feildのvalueオプションが存在しないため空であることの検証は行っていない
      expect(page).to have_field("q_updated_at_gteq", with: "")
      expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
      expect(page).to have_field("q_created_at_gteq", with: "")
      expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
      #group_nameのfeildのvalueオプションが存在しないため空であることの検証は行っていない
      expect(page).to have_button("save-button")
      expect(page).not_to have_button("update")
      expect(page).not_to have_link("cancel")
    end
    
    describe "pagination" do
      #一覧表示がデフォルト(25件)表示であること
      let(:create_data) do
        26.times do
          FactoryGirl.create(:group)
        end
      end
      
      context "the first page" do
        it "25 display" do
          expect(page).to have_css("tbody tr", count: 25)
        end
      end
      
      context "the second page" do
        before do
          click_link("2")
        end
        it "1 display" do
          expect(page).to have_css("tbody tr", count: 1)
        end
      end
    end
  end
  
  describe "search" do
    before do
      fill_in_search_condition
      click_button("refresh-button")
    end
    
    describe "search name" do
      let(:create_data) do
        FactoryGirl.create(:group, name: "#{name}1")
        FactoryGirl.create(:group, name: "#{name}2")
        FactoryGirl.create(:group, name: "hoge")
      end
      let(:name) { "グループ" }
      context "value that is not registered" do
        let(:fill_in_search_condition) { fill_in("q_name_cont", with: "abcd") }
        it "input keep content" do
          expect(page).to have_field("q_name_cont", with: "abcd")
          expect(page).to have_field("q_updated_at_gteq", with: "")
          expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
          expect(page).to have_field("q_created_at_gteq", with: "")
          expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
        end
        it "zero result" do
          expect(page).to have_css("tbody tr", count: 0)
        end
      end
      context "value that is registered" do
        let(:fill_in_search_condition) { fill_in("q_name_cont", with: name) }
        it "input keep content" do
          expect(page).to have_field("q_name_cont", with: name)
          expect(page).to have_field("q_updated_at_gteq", with: "")
          expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
          expect(page).to have_field("q_created_at_gteq", with: "")
          expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
        end
        it { expect(page).to have_css("tbody tr", count: 2) }
      end
    end
    describe "search date" do
      let(:create_data) do
        FactoryGirl.create(:group, created_at: created_at_1, updated_at: updated_at_1)
        FactoryGirl.create(:group, created_at: created_at_2, updated_at: updated_at_2)
        FactoryGirl.create(:group, created_at: created_at_3, updated_at: updated_at_3)
      end
      let(:created_at_1) { Date.today.prev_day.strftime("%Y-%m-%d") }
      let(:created_at_2) { Date.today.strftime("%Y-%m-%d") }
      let(:created_at_3) { Date.today.next_day.strftime("%Y-%m-%d") }
      
      let(:updated_at_1) { Date.today.prev_day.strftime("%Y-%m-%d") }
      let(:updated_at_2) { Date.today.strftime("%Y-%m-%d") }
      let(:updated_at_3) { Date.today.next_day.strftime("%Y-%m-%d") }

      describe "updated_at" do
        context "value that is not registered" do
          context "input from" do
            let(:fill_in_search_condition) { fill_in("q_updated_at_gteq", with: "9999-12-31") }
            it "input keep content" do
              #TODO nameのtext_feildのvalueがないため""(空文字)でのマッチングができない
              #expect(page).to have_field("q_name_cont", with: "")
              expect(page).to have_field("q_updated_at_gteq", with: "9999-12-31")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 0)
            end
          end
          context "input to" do
            let(:fill_in_search_condition) { fill_in("q_updated_at_lteq_end_of_day", with: "1000-12-31") }
            it "input keep content" do
              #nameのtext_feildのvalueがないため""(空文字)でのマッチングができない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "1000-12-31")
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 0)
            end
          end
          context "input from and to" do
            let(:fill_in_search_condition) do
              fill_in("q_updated_at_gteq", with: "9999-12-31")
              fill_in("q_updated_at_lteq_end_of_day", with: "9999-12-31")
            end
            it "input keep content" do
              # nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "9999-12-31")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "9999-12-31")
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 0)
            end
          end
        end
        context "value that is registered" do
          context "input from" do
            let(:fill_in_search_condition) { fill_in("q_updated_at_gteq", with: updated_at_1) }
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: updated_at_1)
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it { expect(page).to have_css("tbody tr", count: 3) }
          end
          context "input to" do
            let(:fill_in_search_condition) { fill_in("q_updated_at_lteq_end_of_day", with: updated_at_2) }
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: updated_at_2)
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 2)
            end
          end
          context "input from and to" do
            let(:fill_in_search_condition) do
               fill_in("q_updated_at_gteq", with: updated_at_1)
               fill_in("q_updated_at_lteq_end_of_day", with: updated_at_2) 
            end
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: updated_at_1)
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: updated_at_2)
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it { expect(page).to have_css("tbody tr", count: 2) }
          end
        end
      end
      describe "created_at" do
        context "value that is not registered" do
          context "input from" do
            let(:fill_in_search_condition) { fill_in("q_created_at_gteq", with: "9999-12-31") }
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: "9999-12-31")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 0)
            end
          end
          context "input to" do
            let(:fill_in_search_condition) { fill_in("q_created_at_lteq_end_of_day", with: "1000-12-31") }
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "1000-12-31")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 0)
            end
          end
          context "input from and to" do
            let(:fill_in_search_condition) do
              fill_in("q_created_at_gteq", with: "9999-12-31")
              fill_in("q_created_at_lteq_end_of_day", with: "9999-12-31")
            end
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: "9999-12-31")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "9999-12-31")
            end
            it "zero result" do
              expect(page).to have_css("tbody tr", count: 0)
            end
          end
        end
        context "value that is registered" do
          context "input from" do
            let(:fill_in_search_condition) { fill_in("q_created_at_gteq", with: created_at_1) }
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: created_at_1)
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: "")
            end
            it { expect(page).to have_css("tbody tr", count: 3) }
          end
          context "input to" do
            let(:fill_in_search_condition) { fill_in("q_created_at_lteq_end_of_day", with: created_at_2) }
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: "")
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: created_at_2)
            end
            it { expect(page).to have_css("tbody tr", count: 2) }
          end
          context "input from and to" do
            let(:fill_in_search_condition) do
               fill_in("q_created_at_gteq", with: created_at_1)
               fill_in("q_created_at_lteq_end_of_day", with: created_at_2)
            end
            it "input keep content" do
              #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
              expect(page).to have_field("q_updated_at_gteq", with: "")
              expect(page).to have_field("q_updated_at_lteq_end_of_day", with: "")
              expect(page).to have_field("q_created_at_gteq", with: created_at_1)
              expect(page).to have_field("q_created_at_lteq_end_of_day", with: created_at_2)
            end
            it { expect(page).to have_css("tbody tr", count: 2) }
          end
        end
      end
      describe "input updated_at and created_at" do
        let(:fill_in_search_condition) do
           fill_in("q_updated_at_gteq", with: updated_at_1)
           fill_in("q_updated_at_lteq_end_of_day", with: updated_at_3)
           fill_in("q_created_at_gteq", with: created_at_1)
           fill_in("q_created_at_lteq_end_of_day", with: created_at_3) 
        end
        it "input keep content" do
          #nameのtext_feildのvalueオプションが存在しないため空であることの検証は行っていない
          expect(page).to have_field("q_updated_at_gteq", with: updated_at_1)
          expect(page).to have_field("q_updated_at_lteq_end_of_day", with: updated_at_3)
          expect(page).to have_field("q_created_at_gteq", with: created_at_1)
          expect(page).to have_field("q_created_at_lteq_end_of_day", with: created_at_3)
        end 
        it { expect(page).to have_css("tbody tr", count: 3) }
      end
    end
  end
  
  describe "sort" do
    let(:create_data) do
      group_1
      group_2
      group_3
    end
    let(:group_1) { FactoryGirl.create(:group, name: "グループ1", created_at: created_at_1, updated_at: updated_at_1) }
    let(:group_2) { FactoryGirl.create(:group, name: "グループ2", created_at: created_at_2, updated_at: updated_at_2) }
    let(:group_3) { FactoryGirl.create(:group, name: "グループ3", created_at: created_at_3, updated_at: updated_at_3) }
    let(:created_at_1) { (DateTime.now - 3).strftime("%Y-%m-%d") }
    let(:created_at_2) { (DateTime.now - 2).strftime("%Y-%m-%d") }
    let(:created_at_3) { (DateTime.now - 1).strftime("%Y-%m-%d") }
    let(:updated_at_1) { created_at_1 }
    let(:updated_at_2) { created_at_2 }
    let(:updated_at_3) { created_at_3 }
    describe "name" do
      before { click_link("name") }
      context "ascending order" do
        it "ascending order display" do
          expect(page).to have_css("tbody tr:eq(1) td:eq(2)", text: group_1.name)
          expect(page).to have_css("tbody tr:eq(2) td:eq(2)", text: group_2.name)
          expect(page).to have_css("tbody tr:eq(3) td:eq(2)", text: group_3.name)
        end
      end
      context "descending order" do
        before { click_link("name") }
        it "descending order display" do
          expect(page).to have_css("tbody tr:eq(1) td:eq(2)", text: group_3.name)
          expect(page).to have_css("tbody tr:eq(2) td:eq(2)", text: group_2.name)
          expect(page).to have_css("tbody tr:eq(3) td:eq(2)", text: group_1.name)
        end
      end
    end
    describe "updated_at" do
      context "ascending order" do
         #画面遷移時updated_atはデフォルトで昇順のソートリンクが付いている
        it "ascending order display" do
          expect(page).to have_css("tbody tr:eq(1) td:eq(4)", text: group_1.updated_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(2) td:eq(4)", text: group_2.updated_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(3) td:eq(4)", text: group_3.updated_at.strftime("%Y-%m-%d"))
        end
      end
      context "descending order" do
        before { click_link("updated-at") }
        it "descending order display" do
          expect(page).to have_css("tbody tr:eq(1) td:eq(4)", text: group_3.updated_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(2) td:eq(4)", text: group_2.updated_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(3) td:eq(4)", text: group_1.updated_at.strftime("%Y-%m-%d"))
        end
      end
    end
    describe "created_at" do
      before { click_link("created-at") }
      context "ascending order" do
        it "ascending order display" do
          expect(page).to have_css("tbody tr:eq(1) td:eq(5)", text: group_1.created_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(2) td:eq(5)", text: group_2.created_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(3) td:eq(5)", text: group_3.created_at.strftime("%Y-%m-%d"))
        end
      end
      context "descending order" do
        before { click_link("created-at") }
        it "descending order display" do
          expect(page).to have_css("tbody tr:eq(1) td:eq(5)", text: group_3.created_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(2) td:eq(5)", text: group_2.created_at.strftime("%Y-%m-%d"))
          expect(page).to have_css("tbody tr:eq(3) td:eq(5)", text: group_1.created_at.strftime("%Y-%m-%d"))
        end
      end
    end
  end
  
  describe "create", js: true do
    pending "テスト内で新規作成ボタンを押下時にモーダルウィンドウが表示されない" do
      #TODO　テスト内で新規作成ボタンを押下時にモーダルウィンドウが表示されないため検証保留
      before do
        new_record_condition
        click_button("save-button")
      end
      context "新規レコード作成が失敗した場合" do
        let(:new_record_condition) { fill_in("group_name", with: "") }
        it "ダイアログの内容が表示されていること" do
        end
      end
      context "新規レコード作成が成功した場合" do
        let(:new_record_condition) { fill_in("group_name", with: "test") }
        it "ダイアログの内容が表示されていること" do
        end
      end
    end
  end
  
  describe "edit screen" do
    let(:create_data) { FactoryGirl.create(:group) }
    before do
      click_link("group-#{create_data.id}-link")
      visit edit_group_path(create_data)
    end
    it "correctly display the label" do
      expect(page).to have_content("Name")
      expect(page).to have_button("update")
      expect(page).to have_link("cancel")
    end
    it "input keep edit" do
      expect(page).to have_field("group_name", with: create_data.name)
    end
    describe "update" do
      before do
        fill_in("group_name", with: name)
        click_button("update")
      end
      context "failure" do
        let(:name) { "" }
        it "not move to the list screen" do
          expect(page).not_to have_content("name")
          expect(page).not_to have_content("updated_at")
          expect(page).not_to have_content("created_at")
          expect(page).not_to have_button("refresh-button")
          expect(page).not_to have_button("save-button")
          expect(page).to have_button("update")
          expect(page).to have_link("cancel")
        end
        it "input keep edit" do
          fill_in("group_name", with: "")
        end
        it "error message" do
          expect(page).to have_content("Name can't be blank")
        end
        it "data is not updated" do
          expect(create_data.reload.name).to eq create_data.name
        end
      end
      context "success" do
        let(:name) { "test" }
        it "move to the list screen" do
          expect(page).to have_content("name")
          expect(page).to have_content("updated-at")
          expect(page).to have_content("created-at")
          expect(page).to have_button("refresh-button")
          expect(page).to have_button("save-button")
          expect(page).not_to have_button("update")
          expect(page).not_to have_link("cancel")
        end
        it "data is updated" do
          expect(create_data.reload.name).to eq name
        end
      end
    end
    describe "cancel" do
      before { click_link("cancel") }
      it "move to the list screen" do
        expect(page).to have_content("name")
        expect(page).to have_content("updated-at")
        expect(page).to have_content("created-at")
        expect(page).to have_button("refresh-button")
        expect(page).to have_button("save-button")
        expect(page).not_to have_button("update")
        expect(page).not_to have_link("cancel")
      end
    end
  end
  
end