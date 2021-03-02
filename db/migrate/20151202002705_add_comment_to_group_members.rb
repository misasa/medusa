class AddCommentToGroupMembers < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:group_members, "グループメンバー")
    change_column_comment(:group_members, :id, "ID")
    change_column_comment(:group_members, :group_id, "グループID")
    change_column_comment(:group_members, :user_id, "ユーザID")
  end
end
