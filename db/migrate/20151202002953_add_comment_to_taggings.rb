class AddCommentToTaggings < ActiveRecord::Migration
  def change
    change_table "taggings" do |t|
      t.comment "タグ付け"
      t.change_comment :id, "ID"
      t.change_comment :tag_id, "タグID"
      t.change_comment :taggable_id, "タグ付け対象ID"
      t.change_comment :taggable_type, "タグ付け対象タイプ"
      t.change_comment :tagger_id, "tagger_id"
      t.change_comment :tagger_type, "tagget_type"
      t.change_comment :context, "コンテキスト"
      t.change_comment :created_at, "作成日時"
    end
  end
end
