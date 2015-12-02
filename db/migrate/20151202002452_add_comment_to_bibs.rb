class AddCommentToBibs < ActiveRecord::Migration
  def change
    change_table "bibs" do |t|
      t.comment "参考文献"
      t.change_comment :id, "ID"
      t.change_comment :entry_type, "エントリ種別"
      t.change_comment :abbreviation, "略称"
      t.change_comment :name, "名称"
      t.change_comment :journal, "雑誌名"
      t.change_comment :year, "出版年"
      t.change_comment :volume, "巻数"
      t.change_comment :number, "号数"
      t.change_comment :pages, "ページ数"
      t.change_comment :month, "出版月"
      t.change_comment :note, "注記"
      t.change_comment :key, "キー"
      t.change_comment :link_url, "リンクURL"
      t.change_comment :doi, "DOI"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
