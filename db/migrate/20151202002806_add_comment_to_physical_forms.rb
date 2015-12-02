class AddCommentToPhysicalForms < ActiveRecord::Migration
  def change
    change_table "physical_forms" do |t|
      t.comment "形状"
      t.change_comment :id, "ID"
      t.change_comment :name, "名称"
      t.change_comment :description, "説明"
      t.change_comment :sesar_sample_type, "SESAR:sample_type"
    end
  end
end
