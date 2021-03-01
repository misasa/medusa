class AddCommentToPlaces < ActiveRecord::Migration[4.2]
  def change
    change_table_comment(:places, "場所")
    change_column_comment(:places, :id, "ID")
    change_column_comment(:places, :name, "名称")
    change_column_comment(:places, :description, "説明")
    change_column_comment(:places, :latitude, "緯度")
    change_column_comment(:places, :longitude, "経度")
    change_column_comment(:places, :elevation, "標高")
    change_column_comment(:places, :created_at, "作成日時")
    change_column_comment(:places, :updated_at, "更新日時")
  end
end
