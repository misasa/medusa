# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140124010521) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "stone_id"
    t.string   "technique"
    t.string   "device"
    t.string   "operator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "analyses", ["stone_id"], name: "index_analyses_on_stone_id", using: :btree

  create_table "attachings", force: true do |t|
    t.integer  "attachment_file_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachings", ["attachable_id"], name: "index_attachings_on_attachable_id", using: :btree
  add_index "attachings", ["attachment_file_id"], name: "index_attachings_on_attachment_file_id", using: :btree

  create_table "attachment_files", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "md5hash"
    t.string   "file_name"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "file_updated_at"
    t.string   "original_geometry"
    t.text     "affine_matrix"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bibs", force: true do |t|
    t.string   "entry_type"
    t.string   "abbreviation"
    t.string   "authorlist"
    t.string   "name"
    t.string   "journal"
    t.string   "year"
    t.string   "volume"
    t.string   "number"
    t.string   "pages"
    t.string   "month"
    t.string   "note"
    t.string   "key"
    t.string   "link_url"
    t.text     "doi"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "box_types", force: true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "boxes", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "position"
    t.string   "path"
    t.integer  "box_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boxes", ["box_type_id"], name: "index_boxes_on_box_type_id", using: :btree
  add_index "boxes", ["parent_id"], name: "index_boxes_on_parent_id", using: :btree

  create_table "category_measurement_items", force: true do |t|
    t.integer "measurement_item_id"
    t.integer "measurement_category_id"
    t.integer "position"
  end

  add_index "category_measurement_items", ["measurement_category_id"], name: "index_category_measurement_items_on_measurement_category_id", using: :btree
  add_index "category_measurement_items", ["measurement_item_id"], name: "index_category_measurement_items_on_measurement_item_id", using: :btree

  create_table "chemistries", force: true do |t|
    t.integer  "analysis_id",         null: false
    t.integer  "measurement_item_id"
    t.string   "info"
    t.float    "value"
    t.string   "label"
    t.string   "unit"
    t.text     "description"
    t.float    "uncertainty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chemistries", ["analysis_id"], name: "index_chemistries_on_analysis_id", using: :btree
  add_index "chemistries", ["measurement_item_id"], name: "index_chemistries_on_measurement_item_id", using: :btree

  create_table "classifications", force: true do |t|
    t.string  "name"
    t.string  "full_name"
    t.text    "description"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
  end

  add_index "classifications", ["parent_id"], name: "index_classifications_on_parent_id", using: :btree

  create_table "global_qrs", force: true do |t|
    t.integer  "record_property_id"
    t.string   "file_name"
    t.string   "content_type"
    t.integer  "file_size"
    t.datetime "file_updated_at"
    t.string   "identifier"
  end

  add_index "global_qrs", ["record_property_id"], name: "index_global_qrs_on_record_property_id", using: :btree

  create_table "group_members", force: true do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurement_categories", force: true do |t|
    t.string "name"
    t.string "description"
    t.text   "unit"
  end

  create_table "measurement_items", force: true do |t|
    t.string "nickname"
    t.text   "description"
    t.string "display_in_html"
    t.string "unit"
    t.string "display_in_tex"
  end

  create_table "physical_forms", force: true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "places", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "elevation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "record_properties", force: true do |t|
    t.integer  "datum_id"
    t.string   "datum_type"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "permission_u"
    t.integer  "permission_g"
    t.integer  "permission_o"
    t.string   "global_id"
    t.boolean  "published",    default: false
    t.datetime "published_at"
  end

  add_index "record_properties", ["datum_id"], name: "index_record_properties_on_datum_id", using: :btree
  add_index "record_properties", ["group_id"], name: "index_record_properties_on_group_id", using: :btree
  add_index "record_properties", ["user_id"], name: "index_record_properties_on_user_id", using: :btree

  create_table "referrings", force: true do |t|
    t.integer  "bib_id"
    t.integer  "referable_id"
    t.string   "referable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referrings", ["bib_id"], name: "index_referrings_on_bib_id", using: :btree
  add_index "referrings", ["referable_id"], name: "index_referrings_on_referable_id", using: :btree

  create_table "spots", force: true do |t|
    t.integer  "attachment_file_id"
    t.string   "name"
    t.text     "description"
    t.float    "spot_x"
    t.float    "spot_y"
    t.string   "target_uid"
    t.float    "radius_in_percent"
    t.string   "stroke_color"
    t.float    "stroke_width"
    t.string   "fill_color"
    t.float    "opacity"
    t.boolean  "with_cross"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spots", ["attachment_file_id"], name: "index_spots_on_attachment_file_id", using: :btree

  create_table "stones", force: true do |t|
    t.string   "name"
    t.string   "stone_type"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "place_id"
    t.integer  "box_id"
    t.integer  "physical_form_id"
    t.integer  "classification_id"
    t.float    "quantity"
    t.string   "quantity_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stones", ["classification_id"], name: "index_stones_on_classification_id", using: :btree
  add_index "stones", ["parent_id"], name: "index_stones_on_parent_id", using: :btree
  add_index "stones", ["physical_form_id"], name: "index_stones_on_physical_form_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "administrator",          default: false, null: false
    t.string   "family_name"
    t.string   "first_name"
    t.text     "description"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
