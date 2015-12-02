class AddCommentToGroupMembers < ActiveRecord::Migration
  def change
    change_table "group_members" do |t|
      t.comment "グループメンバー"
      t.change_comment :id, "ID"
      t.change_comment :group_id, "グループID"
      t.change_comment :user_id, "ユーザID"
    end
  end
end
