class AddCommentToTaggings < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:taggings, "タグ付け")
    change_column_comment(:taggings, :id, "ID")
    change_column_comment(:taggings, :tag_id, "タグID")
    change_column_comment(:taggings, :taggable_id, "タグ付け対象ID")
    change_column_comment(:taggings, :taggable_type, "タグ付け対象タイプ")
    change_column_comment(:taggings, :tagger_id, "tagger_id")
    change_column_comment(:taggings, :tagger_type, "tagget_type")
    change_column_comment(:taggings, :context, "コンテキスト")
    change_column_comment(:taggings, :created_at, "作成日時")
  end
end
