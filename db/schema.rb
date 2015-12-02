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

ActiveRecord::Schema.define(version: 20151202003030) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: true, comment: "分析" do |t|
    t.string   "name",         comment: "名称"
    t.text     "description",  comment: "説明"
    t.integer  "specimen_id",  comment: "標本ID"
    t.string   "operator",     comment: "オペレータ"
    t.datetime "created_at",   comment: "作成日時"
    t.datetime "updated_at",   comment: "更新日時"
    t.integer  "technique_id", comment: "分析手法ID"
    t.integer  "device_id",    comment: "分析機器ID"
  end

  add_index "analyses", ["device_id"], name: "index_analyses_on_device_id", using: :btree
  add_index "analyses", ["specimen_id"], name: "index_analyses_on_specimen_id", using: :btree
  add_index "analyses", ["technique_id"], name: "index_analyses_on_technique_id", using: :btree

  create_table "attachings", force: true, comment: "添付" do |t|
    t.integer  "attachment_file_id", comment: "添付ファイルID"
    t.integer  "attachable_id",      comment: "添付先ID"
    t.string   "attachable_type",    comment: "添付先タイプ"
    t.integer  "position",           comment: "表示位置"
    t.datetime "created_at",         comment: "作成日時"
    t.datetime "updated_at",         comment: "更新日時"
  end

  add_index "attachings", ["attachable_id"], name: "index_attachings_on_attachable_id", using: :btree
  add_index "attachings", ["attachment_file_id", "attachable_id", "attachable_type"], name: "index_on_attachings_attachable_type_and_id_and_file_id", unique: true, using: :btree
  add_index "attachings", ["attachment_file_id"], name: "index_attachings_on_attachment_file_id", using: :btree

  create_table "attachment_files", force: true, comment: "添付ファイル" do |t|
    t.string   "name",              comment: "名称"
    t.text     "description",       comment: "説明"
    t.string   "md5hash",           comment: "MD5"
    t.string   "data_file_name",    comment: "ファイル名"
    t.string   "data_content_type", comment: "MIME Content-Type"
    t.integer  "data_file_size",    comment: "ファイルサイズ"
    t.datetime "data_updated_at",   comment: "ファイル更新日時"
    t.string   "original_geometry", comment: "画素数"
    t.text     "affine_matrix",     comment: "アフィン変換行列"
    t.datetime "created_at",        comment: "作成日時"
    t.datetime "updated_at",        comment: "更新日時"
  end

  create_table "authors", force: true, comment: "著者" do |t|
    t.string   "name",       comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "bib_authors", force: true, comment: "参考文献著者" do |t|
    t.integer "bib_id",    comment: "参考文献ID"
    t.integer "author_id", comment: "著者ID"
    t.integer "priority",  comment: "優先度"
  end

  add_index "bib_authors", ["author_id"], name: "index_bib_authors_on_author_id", using: :btree
  add_index "bib_authors", ["bib_id"], name: "index_bib_authors_on_bib_id", using: :btree

  create_table "bibs", force: true, comment: "参考文献" do |t|
    t.string   "entry_type",   comment: "エントリ種別"
    t.string   "abbreviation", comment: "略称"
    t.string   "name",         comment: "名称"
    t.string   "journal",      comment: "雑誌名"
    t.string   "year",         comment: "出版年"
    t.string   "volume",       comment: "巻数"
    t.string   "number",       comment: "号数"
    t.string   "pages",        comment: "ページ数"
    t.string   "month",        comment: "出版月"
    t.string   "note",         comment: "注記"
    t.string   "key",          comment: "キー"
    t.string   "link_url",     comment: "リンクURL"
    t.text     "doi",          comment: "DOI"
    t.datetime "created_at",   comment: "作成日時"
    t.datetime "updated_at",   comment: "更新日時"
  end

  create_table "box_types", force: true, comment: "保管場所種別" do |t|
    t.string "name",        comment: "名称"
    t.text   "description", comment: "説明"
  end

  create_table "boxes", force: true, comment: "保管場所" do |t|
    t.string   "name",        comment: "名称"
    t.integer  "parent_id",   comment: "親保管場所ID"
    t.integer  "position",    comment: "表示位置"
    t.string   "path",        comment: "保管場所パス"
    t.integer  "box_type_id", comment: "保管場所種別ID"
    t.datetime "created_at",  comment: "作成日時"
    t.datetime "updated_at",  comment: "更新日時"
  end

  add_index "boxes", ["box_type_id"], name: "index_boxes_on_box_type_id", using: :btree
  add_index "boxes", ["parent_id"], name: "index_boxes_on_parent_id", using: :btree

  create_table "category_measurement_items", force: true, comment: "測定種別別測定項目定義" do |t|
    t.integer "measurement_item_id",     comment: "測定項目ID"
    t.integer "measurement_category_id", comment: "測定種別ID"
    t.integer "position",                comment: "表示位置"
    t.integer "unit_id",                 comment: "単位ID"
    t.integer "scale",                   comment: "有効精度"
  end

  add_index "category_measurement_items", ["measurement_category_id"], name: "index_category_measurement_items_on_measurement_category_id", using: :btree
  add_index "category_measurement_items", ["measurement_item_id"], name: "index_category_measurement_items_on_measurement_item_id", using: :btree

  create_table "chemistries", force: true, comment: "分析要素" do |t|
    t.integer  "analysis_id",         null: false, comment: "分析ID"
    t.integer  "measurement_item_id",              comment: "測定項目ID"
    t.string   "info",                             comment: "情報"
    t.float    "value",                            comment: "測定値"
    t.string   "label",                            comment: "ラベル"
    t.text     "description",                      comment: "説明"
    t.float    "uncertainty",                      comment: "不確実性"
    t.datetime "created_at",                       comment: "作成日時"
    t.datetime "updated_at",                       comment: "更新日時"
    t.integer  "unit_id",             null: false, comment: "単位ID"
  end

  add_index "chemistries", ["analysis_id"], name: "index_chemistries_on_analysis_id", using: :btree
  add_index "chemistries", ["measurement_item_id"], name: "index_chemistries_on_measurement_item_id", using: :btree

  create_table "classifications", force: true, comment: "分類" do |t|
    t.string  "name",                 comment: "名称"
    t.string  "full_name",            comment: "正式名称"
    t.text    "description",          comment: "説明"
    t.integer "parent_id",            comment: "親分類ID"
    t.integer "lft",                  comment: "lft"
    t.integer "rgt",                  comment: "rgt"
    t.string  "sesar_material",       comment: "SESAR:material"
    t.string  "sesar_classification", comment: "SESAR:classification"
  end

  add_index "classifications", ["parent_id"], name: "index_classifications_on_parent_id", using: :btree

  create_table "custom_attributes", force: true, comment: "カスタム属性" do |t|
    t.string   "name",       comment: "名称"
    t.string   "sesar_name", comment: "SESAR属性名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "devices", force: true, comment: "分析機器" do |t|
    t.string   "name",       comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "global_qrs", force: true, comment: "QRコード" do |t|
    t.integer  "record_property_id", comment: "レコードプロパティID"
    t.string   "file_name",          comment: "ファイル名"
    t.string   "content_type",       comment: "MIME Content-Type"
    t.integer  "file_size",          comment: "ファイルサイズ"
    t.datetime "file_updated_at",    comment: "ファイル更新日時"
    t.string   "identifier",         comment: "識別子"
  end

  add_index "global_qrs", ["record_property_id"], name: "index_global_qrs_on_record_property_id", using: :btree

  create_table "group_members", force: true, comment: "グループメンバー" do |t|
    t.integer "group_id", null: false, comment: "グループID"
    t.integer "user_id",  null: false, comment: "ユーザID"
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "groups", force: true, comment: "グループ" do |t|
    t.string   "name",       null: false, comment: "名称"
    t.datetime "created_at",              comment: "作成日時"
    t.datetime "updated_at",              comment: "更新日時"
  end

  create_table "measurement_categories", force: true, comment: "測定種別" do |t|
    t.string  "name",        comment: "名称"
    t.string  "description", comment: "説明"
    t.integer "unit_id",     comment: "単位ID"
  end

  create_table "measurement_items", force: true, comment: "測定項目" do |t|
    t.string  "nickname",        comment: "名称"
    t.text    "description",     comment: "説明"
    t.string  "display_in_html", comment: "HTML表記"
    t.string  "display_in_tex",  comment: "TEX表記"
    t.integer "unit_id",         comment: "単位ID"
  end

  create_table "omniauths", force: true, comment: "シングルサインオン情報" do |t|
    t.integer  "user_id",    null: false, comment: "ユーザID"
    t.string   "provider",   null: false, comment: "プロバイダ"
    t.string   "uid",        null: false, comment: "UID"
    t.datetime "created_at",              comment: "作成日時"
    t.datetime "updated_at",              comment: "更新日時"
  end

  add_index "omniauths", ["provider", "uid"], name: "index_omniauths_on_provider_and_uid", unique: true, using: :btree

  create_table "paths", force: true, comment: "保管場所履歴" do |t|
    t.integer  "datum_id",                       comment: "対象ID"
    t.string   "datum_type",                     comment: "対象種別"
    t.integer  "ids",               array: true, comment: "保管場所パス"
    t.datetime "brought_in_at",                  comment: "持込日時"
    t.datetime "brought_out_at",                 comment: "持出日時"
    t.integer  "brought_in_by_id",               comment: "持込者ID"
    t.integer  "brought_out_by_id",              comment: "持出者ID"
  end

  add_index "paths", ["datum_id", "datum_type"], name: "index_paths_on_datum_id_and_datum_type", using: :btree
  add_index "paths", ["ids"], name: "index_paths_on_ids", using: :gin

  create_table "physical_forms", force: true, comment: "形状" do |t|
    t.string "name",              comment: "名称"
    t.text   "description",       comment: "説明"
    t.string "sesar_sample_type", comment: "SESAR:sample_type"
  end

  create_table "places", force: true, comment: "場所" do |t|
    t.string   "name",        comment: "名称"
    t.text     "description", comment: "説明"
    t.float    "latitude",    comment: "緯度"
    t.float    "longitude",   comment: "経度"
    t.float    "elevation",   comment: "標高"
    t.datetime "created_at",  comment: "作成日時"
    t.datetime "updated_at",  comment: "更新日時"
  end

  create_table "record_properties", force: true, comment: "レコードプロパティ" do |t|
    t.integer  "datum_id",                                    comment: "レコードID"
    t.string   "datum_type",                                  comment: "レコード種別"
    t.integer  "user_id",                                     comment: "ユーザID"
    t.integer  "group_id",                                    comment: "グループID"
    t.string   "global_id",                                   comment: "グローバルID"
    t.boolean  "published",      default: false,              comment: "公開済フラグ"
    t.datetime "published_at",                                comment: "公開日時"
    t.boolean  "owner_readable", default: true,  null: false, comment: "読取許可（所有者）"
    t.boolean  "owner_writable", default: true,  null: false, comment: "書込許可（所有者）"
    t.boolean  "group_readable", default: true,  null: false, comment: "読取許可（グループ）"
    t.boolean  "group_writable", default: true,  null: false, comment: "書込許可（グループ）"
    t.boolean  "guest_readable", default: false, null: false, comment: "読取許可（その他）"
    t.boolean  "guest_writable", default: false, null: false, comment: "書込許可（その他）"
    t.string   "name",                                        comment: "名称"
    t.datetime "created_at",                                  comment: "作成日時"
    t.datetime "updated_at",                                  comment: "更新日時"
  end

  add_index "record_properties", ["datum_id"], name: "index_record_properties_on_datum_id", using: :btree
  add_index "record_properties", ["group_id"], name: "index_record_properties_on_group_id", using: :btree
  add_index "record_properties", ["user_id"], name: "index_record_properties_on_user_id", using: :btree

  create_table "referrings", force: true, comment: "参照" do |t|
    t.integer  "bib_id",         comment: "参考文献ID"
    t.integer  "referable_id",   comment: "参照元ID"
    t.string   "referable_type", comment: "参照元種別"
    t.datetime "created_at",     comment: "作成日時"
    t.datetime "updated_at",     comment: "更新日時"
  end

  add_index "referrings", ["bib_id", "referable_id", "referable_type"], name: "index_referrings_on_bib_id_and_referable_id_and_referable_type", unique: true, using: :btree
  add_index "referrings", ["bib_id"], name: "index_referrings_on_bib_id", using: :btree
  add_index "referrings", ["referable_id"], name: "index_referrings_on_referable_id", using: :btree

  create_table "specimen_custom_attributes", force: true, comment: "標本別カスタム属性" do |t|
    t.integer  "specimen_id",         comment: "標本ID"
    t.integer  "custom_attribute_id", comment: "カスタム属性ID"
    t.string   "value",               comment: "値"
    t.datetime "created_at",          comment: "作成日時"
    t.datetime "updated_at",          comment: "更新日時"
  end

  add_index "specimen_custom_attributes", ["custom_attribute_id"], name: "index_specimen_custom_attributes_on_custom_attribute_id", using: :btree
  add_index "specimen_custom_attributes", ["specimen_id"], name: "index_specimen_custom_attributes_on_specimen_id", using: :btree

  create_table "specimens", force: true, comment: "標本" do |t|
    t.string   "name",                                comment: "名称"
    t.string   "specimen_type",                       comment: "標本種別"
    t.text     "description",                         comment: "説明"
    t.integer  "parent_id",                           comment: "親標本ID"
    t.integer  "place_id",                            comment: "場所ID"
    t.integer  "box_id",                              comment: "保管場所ID"
    t.integer  "physical_form_id",                    comment: "形状ID"
    t.integer  "classification_id",                   comment: "分類ID"
    t.float    "quantity",                            comment: "数量"
    t.string   "quantity_unit",                       comment: "数量単位"
    t.datetime "created_at",                          comment: "作成日時"
    t.datetime "updated_at",                          comment: "更新日時"
    t.string   "igsn",                      limit: 9, comment: "IGSN"
    t.integer  "age_min",                             comment: "年代（最小）"
    t.integer  "age_max",                             comment: "年代（最大）"
    t.string   "age_unit",                            comment: "年代単位"
    t.string   "size",                                comment: "サイズ"
    t.string   "size_unit",                           comment: "サイズ単位"
    t.datetime "collected_at",                        comment: "採取日時"
    t.string   "collection_date_precision",           comment: "採取日時精度"
    t.string   "collector",                           comment: "採取者"
    t.string   "collector_detail",                    comment: "採取詳細情報"
  end

  add_index "specimens", ["classification_id"], name: "index_specimens_on_classification_id", using: :btree
  add_index "specimens", ["parent_id"], name: "index_specimens_on_parent_id", using: :btree
  add_index "specimens", ["physical_form_id"], name: "index_specimens_on_physical_form_id", using: :btree

  create_table "spots", force: true, comment: "分析点" do |t|
    t.integer  "attachment_file_id", comment: "添付ファイルID"
    t.string   "name",               comment: "名称"
    t.text     "description",        comment: "説明"
    t.float    "spot_x",             comment: "X座標"
    t.float    "spot_y",             comment: "Y座標"
    t.string   "target_uid",         comment: "対象UID"
    t.float    "radius_in_percent",  comment: "半径（％）"
    t.string   "stroke_color",       comment: "線色"
    t.float    "stroke_width",       comment: "線幅"
    t.string   "fill_color",         comment: "塗り潰し色"
    t.float    "opacity",            comment: "透明度"
    t.boolean  "with_cross",         comment: "クロス表示フラグ"
    t.datetime "created_at",         comment: "作成日時"
    t.datetime "updated_at",         comment: "更新日時"
  end

  add_index "spots", ["attachment_file_id"], name: "index_spots_on_attachment_file_id", using: :btree

  create_table "table_analyses", force: true, comment: "表内分析情報" do |t|
    t.integer  "table_id",    comment: "表ID"
    t.integer  "specimen_id", comment: "標本ID"
    t.integer  "analysis_id", comment: "分析ID"
    t.integer  "priority",    comment: "優先度"
    t.datetime "created_at",  comment: "作成日時"
    t.datetime "updated_at",  comment: "更新日時"
  end

  add_index "table_analyses", ["analysis_id"], name: "index_table_analyses_on_analysis_id", using: :btree
  add_index "table_analyses", ["specimen_id"], name: "index_table_analyses_on_specimen_id", using: :btree
  add_index "table_analyses", ["table_id"], name: "index_table_analyses_on_table_id", using: :btree

  create_table "table_specimens", force: true, comment: "表内標本情報" do |t|
    t.integer  "table_id",    comment: "表ID"
    t.integer  "specimen_id", comment: "標本ID"
    t.integer  "position",    comment: "表示位置"
    t.datetime "created_at",  comment: "作成日時"
    t.datetime "updated_at",  comment: "更新日時"
  end

  add_index "table_specimens", ["specimen_id"], name: "index_table_specimens_on_specimen_id", using: :btree
  add_index "table_specimens", ["table_id"], name: "index_table_specimens_on_table_id", using: :btree

  create_table "tables", force: true, comment: "表" do |t|
    t.integer  "bib_id",                  comment: "参考文献ID"
    t.integer  "measurement_category_id", comment: "測定種別ID"
    t.text     "description",             comment: "説明"
    t.boolean  "with_average",            comment: "平均値表示フラグ"
    t.boolean  "with_place",              comment: "場所表示フラグ"
    t.datetime "created_at",              comment: "作成日時"
    t.datetime "updated_at",              comment: "更新日時"
    t.boolean  "with_age",                comment: "年代表示フラグ"
    t.string   "age_unit",                comment: "年代単位"
  end

  add_index "tables", ["bib_id"], name: "index_tables_on_bib_id", using: :btree
  add_index "tables", ["measurement_category_id"], name: "index_tables_on_measurement_category_id", using: :btree

  create_table "taggings", force: true, comment: "タグ付け" do |t|
    t.integer  "tag_id",                    comment: "タグID"
    t.integer  "taggable_id",               comment: "タグ付け対象ID"
    t.string   "taggable_type",             comment: "タグ付け対象タイプ"
    t.integer  "tagger_id",                 comment: "tagger_id"
    t.string   "tagger_type",               comment: "tagget_type"
    t.string   "context",       limit: 128, comment: "コンテキスト"
    t.datetime "created_at",                comment: "作成日時"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true, comment: "タグ" do |t|
    t.string "name", comment: "名称"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "techniques", force: true, comment: "分析手法" do |t|
    t.string   "name",       comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "units", force: true, comment: "単位" do |t|
    t.string   "name",                               comment: "名称"
    t.datetime "created_at",                         comment: "作成日時"
    t.datetime "updated_at",                         comment: "更新日時"
    t.float    "conversion",            null: false, comment: "変換"
    t.string   "html",       limit: 10, null: false, comment: "HTML表記"
    t.string   "text",       limit: 10, null: false, comment: "テキスト"
  end

  create_table "users", force: true, comment: "ユーザ" do |t|
    t.string   "email",                                               comment: "Eメールアドレス"
    t.string   "encrypted_password",     default: "",    null: false, comment: "暗号化パスワード"
    t.string   "reset_password_token",                                comment: "パスワードリセット"
    t.datetime "reset_password_sent_at",                              comment: "リセットパスワード送信日時"
    t.datetime "remember_created_at",                                 comment: "ログイン状態保持作成日時"
    t.integer  "sign_in_count",          default: 0,     null: false, comment: "サインイン回数"
    t.datetime "current_sign_in_at",                                  comment: "今回サインイン日時"
    t.datetime "last_sign_in_at",                                     comment: "前回サインイン日時"
    t.string   "current_sign_in_ip",                                  comment: "今回サインインIPアドレス"
    t.string   "last_sign_in_ip",                                     comment: "前回サインインIPアドレス"
    t.datetime "created_at",                                          comment: "作成日時"
    t.datetime "updated_at",                                          comment: "更新日時"
    t.boolean  "administrator",          default: false, null: false, comment: "管理者フラグ"
    t.string   "family_name",                                         comment: "姓"
    t.string   "first_name",                                          comment: "名"
    t.text     "description",                                         comment: "説明"
    t.string   "username",                               null: false, comment: "ユーザ名"
    t.integer  "box_id",                                              comment: "保管場所ID"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
