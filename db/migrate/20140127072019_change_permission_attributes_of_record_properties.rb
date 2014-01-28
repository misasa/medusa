class ChangePermissionAttributesOfRecordProperties < ActiveRecord::Migration
  def change
    change_table :record_properties do |t|
      t.boolean :owner_readable, null: false, default: true
      t.boolean :owner_writable, null: false, default: true
      t.boolean :group_readable, null: false, default: true
      t.boolean :group_writable, null: false, default: true
      t.boolean :guest_readable, null: false, default: false
      t.boolean :guest_writable, null: false, default: false
      t.remove :permission_u, :permission_g, :permission_o
    end
  end
end
