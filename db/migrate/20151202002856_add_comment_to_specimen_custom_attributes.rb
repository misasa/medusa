class AddCommentToSpecimenCustomAttributes < ActiveRecord::Migration
  def change
    change_table "specimen_custom_attributes" do |t|
      t.comment "標本別カスタム属性"
      t.change_comment :id, "ID"
      t.change_comment :specimen_id, "標本ID"
      t.change_comment :custom_attribute_id, "カスタム属性ID"
      t.change_comment :value, "値"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
