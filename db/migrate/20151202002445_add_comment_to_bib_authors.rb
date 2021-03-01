class AddCommentToBibAuthors < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:bib_authors, "参考文献著者")
    change_column_comment(:bib_authors, :id, "ID")
    change_column_comment(:bib_authors, :bib_id, "参考文献ID")
    change_column_comment(:bib_authors, :author_id, "著者ID")
    change_column_comment(:bib_authors, :priority, "優先度")
  end
end
