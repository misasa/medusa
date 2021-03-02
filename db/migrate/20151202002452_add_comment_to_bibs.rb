class AddCommentToBibs < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:bibs, "参考文献")
    change_column_comment(:bibs, :id, "ID")
    change_column_comment(:bibs, :entry_type, "エントリ種別")
    change_column_comment(:bibs, :abbreviation, "略称")
    change_column_comment(:bibs, :name, "名称")
    change_column_comment(:bibs, :journal, "雑誌名")
    change_column_comment(:bibs, :year, "出版年")
    change_column_comment(:bibs, :volume, "巻数")
    change_column_comment(:bibs, :number, "号数")
    change_column_comment(:bibs, :pages, "ページ数")
    change_column_comment(:bibs, :month, "出版月")
    change_column_comment(:bibs, :note, "注記")
    change_column_comment(:bibs, :key, "キー")
    change_column_comment(:bibs, :link_url, "リンクURL")
    change_column_comment(:bibs, :doi, "DOI")
    change_column_comment(:bibs, :created_at, "作成日時")
    change_column_comment(:bibs, :updated_at, "更新日時")
  end
end
