class AddCommentToPlaces < ActiveRecord::Migration
  def change
    change_table "places" do |t|
      t.comment "場所"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
      t.change_comment :latitude, "緯度"
      t.change_comment :longitude, "経度"
      t.change_comment :elevation, "標高"
      t.change_comment :created_at, "作成日時"
      t.change_comment :updated_at, "更新日時"
    end
  end
end
