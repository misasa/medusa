# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_10_021858) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", id: { type: :serial, comment: "ID" }, comment: "分析", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
    t.integer "specimen_id", comment: "標本ID"
    t.string "operator", limit: 255, comment: "オペレータ"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.integer "technique_id", comment: "分析手法ID"
    t.integer "device_id", comment: "分析機器ID"
    t.integer "fits_file_id"
    t.index ["device_id"], name: "index_analyses_on_device_id"
    t.index ["specimen_id"], name: "index_analyses_on_specimen_id"
    t.index ["technique_id"], name: "index_analyses_on_technique_id"
  end

  create_table "attachings", id: { type: :serial, comment: "ID" }, comment: "添付", force: :cascade do |t|
    t.integer "attachment_file_id", comment: "添付ファイルID"
    t.integer "attachable_id", comment: "添付先ID"
    t.string "attachable_type", limit: 255, comment: "添付先タイプ"
    t.integer "position", comment: "表示位置"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.index ["attachable_id"], name: "index_attachings_on_attachable_id"
    t.index ["attachment_file_id", "attachable_id", "attachable_type"], name: "index_on_attachings_attachable_type_and_id_and_file_id", unique: true
    t.index ["attachment_file_id"], name: "index_attachings_on_attachment_file_id"
  end

  create_table "attachment_files", id: { type: :serial, comment: "ID" }, comment: "添付ファイル", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
    t.string "md5hash", limit: 255, comment: "MD5"
    t.string "data_file_name", limit: 255, comment: "ファイル名"
    t.string "data_content_type", limit: 255, comment: "MIME Content-Type"
    t.integer "data_file_size", comment: "ファイルサイズ"
    t.datetime "data_updated_at", comment: "ファイル更新日時"
    t.string "original_geometry", limit: 255, comment: "画素数"
    t.text "affine_matrix", comment: "アフィン変換行列"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "authors", id: { type: :serial, comment: "ID" }, comment: "著者", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "bib_authors", id: { type: :serial, comment: "ID" }, comment: "参考文献著者", force: :cascade do |t|
    t.integer "bib_id", comment: "参考文献ID"
    t.integer "author_id", comment: "著者ID"
    t.integer "priority", comment: "優先度"
    t.index ["author_id"], name: "index_bib_authors_on_author_id"
    t.index ["bib_id"], name: "index_bib_authors_on_bib_id"
  end

  create_table "bibs", id: { type: :serial, comment: "ID" }, comment: "参考文献", force: :cascade do |t|
    t.string "entry_type", limit: 255, comment: "エントリ種別"
    t.string "abbreviation", limit: 255, comment: "略称"
    t.string "name", limit: 255, comment: "名称"
    t.string "journal", limit: 255, comment: "雑誌名"
    t.string "year", limit: 255, comment: "出版年"
    t.string "volume", limit: 255, comment: "巻数"
    t.string "number", limit: 255, comment: "号数"
    t.string "pages", limit: 255, comment: "ページ数"
    t.string "month", limit: 255, comment: "出版月"
    t.string "note", limit: 255, comment: "注記"
    t.string "key", limit: 255, comment: "キー"
    t.string "link_url", limit: 255, comment: "リンクURL"
    t.text "doi", comment: "DOI"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.text "abstract"
    t.text "summary"
  end

  create_table "box_types", id: { type: :serial, comment: "ID" }, comment: "保管場所種別", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
  end

  create_table "boxes", id: { type: :serial, comment: "ID" }, comment: "保管場所", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.integer "parent_id", comment: "親保管場所ID"
    t.integer "position", comment: "表示位置"
    t.string "path", limit: 255, comment: "保管場所パス"
    t.integer "box_type_id", comment: "保管場所種別ID"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.string "description", limit: 255, comment: "説明"
    t.float "quantity", comment: "数量"
    t.string "quantity_unit", limit: 255, comment: "数量単位"
    t.boolean "fixed_in_box", default: false, null: false, comment: "固定格納フラグ"
    t.index ["box_type_id"], name: "index_boxes_on_box_type_id"
    t.index ["parent_id"], name: "index_boxes_on_parent_id"
  end

  create_table "category_measurement_items", id: { type: :serial, comment: "ID" }, comment: "測定種別別測定項目定義", force: :cascade do |t|
    t.integer "measurement_item_id", comment: "測定項目ID"
    t.integer "measurement_category_id", comment: "測定種別ID"
    t.integer "position", comment: "表示位置"
    t.integer "unit_id", comment: "単位ID"
    t.integer "scale", comment: "有効精度"
    t.index ["measurement_category_id"], name: "index_category_measurement_items_on_measurement_category_id"
    t.index ["measurement_item_id"], name: "index_category_measurement_items_on_measurement_item_id"
  end

  create_table "chemistries", id: { type: :serial, comment: "ID" }, comment: "分析要素", force: :cascade do |t|
    t.integer "analysis_id", null: false, comment: "分析ID"
    t.integer "measurement_item_id", comment: "測定項目ID"
    t.string "info", limit: 255, comment: "情報"
    t.float "value", comment: "測定値"
    t.string "label", limit: 255, comment: "ラベル"
    t.text "description", comment: "説明"
    t.float "uncertainty", comment: "不確実性"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.integer "unit_id", null: false, comment: "単位ID"
    t.index ["analysis_id"], name: "index_chemistries_on_analysis_id"
    t.index ["measurement_item_id"], name: "index_chemistries_on_measurement_item_id"
  end

  create_table "classifications", id: { type: :serial, comment: "ID" }, comment: "分類", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.string "full_name", limit: 255, comment: "正式名称"
    t.text "description", comment: "説明"
    t.integer "parent_id", comment: "親分類ID"
    t.integer "lft", comment: "lft"
    t.integer "rgt", comment: "rgt"
    t.string "sesar_material", limit: 255, comment: "SESAR:material"
    t.string "sesar_classification", limit: 255, comment: "SESAR:classification"
    t.index ["parent_id"], name: "index_classifications_on_parent_id"
  end

  create_table "custom_attributes", id: { type: :serial, comment: "ID" }, comment: "カスタム属性", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.string "sesar_name", limit: 255, comment: "SESAR属性名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "devices", id: { type: :serial, comment: "ID" }, comment: "分析機器", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "divides", id: :serial, comment: "分取", force: :cascade do |t|
    t.integer "before_specimen_quantity_id", comment: "分取前試料量ID"
    t.boolean "divide_flg", default: false, null: false, comment: "分取フラグ"
    t.string "log", limit: 255, comment: "ログ"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["before_specimen_quantity_id"], name: "index_divides_on_before_specimen_quantity_id"
  end

  create_table "global_qrs", id: { type: :serial, comment: "ID" }, comment: "QRコード", force: :cascade do |t|
    t.integer "record_property_id", comment: "レコードプロパティID"
    t.string "file_name", limit: 255, comment: "ファイル名"
    t.string "content_type", limit: 255, comment: "MIME Content-Type"
    t.integer "file_size", comment: "ファイルサイズ"
    t.datetime "file_updated_at", comment: "ファイル更新日時"
    t.string "identifier", limit: 255, comment: "識別子"
    t.index ["record_property_id"], name: "index_global_qrs_on_record_property_id"
  end

  create_table "group_members", id: { type: :serial, comment: "ID" }, comment: "グループメンバー", force: :cascade do |t|
    t.integer "group_id", null: false, comment: "グループID"
    t.integer "user_id", null: false, comment: "ユーザID"
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", id: { type: :serial, comment: "ID" }, comment: "グループ", force: :cascade do |t|
    t.string "name", limit: 255, null: false, comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "measurement_categories", id: { type: :serial, comment: "ID" }, comment: "測定種別", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.string "description", limit: 255, comment: "説明"
    t.integer "unit_id", comment: "単位ID"
    t.integer "scale", comment: "有効精度"
    t.boolean "is_template", default: false, null: false
  end

  create_table "measurement_items", id: { type: :serial, comment: "ID" }, comment: "測定項目", force: :cascade do |t|
    t.string "nickname", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
    t.string "display_in_html", limit: 255, comment: "HTML表記"
    t.string "display_in_tex", limit: 255, comment: "TEX表記"
    t.integer "unit_id", comment: "単位ID"
    t.integer "scale", comment: "有効精度"
  end

  create_table "omniauths", id: { type: :serial, comment: "ID" }, comment: "シングルサインオン情報", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.string "provider", limit: 255, null: false, comment: "プロバイダ"
    t.string "uid", limit: 255, null: false, comment: "UID"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.index ["provider", "uid"], name: "index_omniauths_on_provider_and_uid", unique: true
  end

  create_table "paths", id: { type: :serial, comment: "ID" }, comment: "保管場所履歴", force: :cascade do |t|
    t.integer "datum_id", comment: "対象ID"
    t.string "datum_type", limit: 255, comment: "対象種別"
    t.integer "ids", comment: "保管場所パス", array: true
    t.datetime "brought_in_at", comment: "持込日時"
    t.datetime "brought_out_at", comment: "持出日時"
    t.integer "brought_in_by_id", comment: "持込者ID"
    t.integer "brought_out_by_id", comment: "持出者ID"
    t.datetime "checked_at", comment: "棚卸日時"
    t.text "note"
    t.index ["datum_id", "datum_type"], name: "index_paths_on_datum_id_and_datum_type"
    t.index ["ids"], name: "index_paths_on_ids", using: :gin
  end

  create_table "physical_forms", id: { type: :serial, comment: "ID" }, comment: "形状", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
    t.string "sesar_sample_type", limit: 255, comment: "SESAR:sample_type"
  end

  create_table "places", id: { type: :serial, comment: "ID" }, comment: "場所", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
    t.float "latitude", comment: "緯度"
    t.float "longitude", comment: "経度"
    t.float "elevation", comment: "標高"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "record_properties", id: { type: :serial, comment: "ID" }, comment: "レコードプロパティ", force: :cascade do |t|
    t.integer "datum_id", comment: "レコードID"
    t.string "datum_type", limit: 255, comment: "レコード種別"
    t.integer "user_id", comment: "ユーザID"
    t.integer "group_id", comment: "グループID"
    t.string "global_id", limit: 255, comment: "グローバルID"
    t.boolean "published", default: false, comment: "公開済フラグ"
    t.datetime "published_at", comment: "公開日時"
    t.boolean "owner_readable", default: true, null: false, comment: "読取許可（所有者）"
    t.boolean "owner_writable", default: true, null: false, comment: "書込許可（所有者）"
    t.boolean "group_readable", default: true, null: false, comment: "読取許可（グループ）"
    t.boolean "group_writable", default: true, null: false, comment: "書込許可（グループ）"
    t.boolean "guest_readable", default: false, null: false, comment: "読取許可（その他）"
    t.boolean "guest_writable", default: false, null: false, comment: "書込許可（その他）"
    t.string "name", limit: 255, comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.boolean "disposed", default: false, null: false, comment: "廃棄フラグ"
    t.datetime "disposed_at", comment: "廃棄日時"
    t.boolean "lost", default: false, null: false, comment: "紛失フラグ"
    t.datetime "lost_at", comment: "紛失日時"
    t.index ["datum_id"], name: "index_record_properties_on_datum_id"
    t.index ["group_id"], name: "index_record_properties_on_group_id"
    t.index ["user_id"], name: "index_record_properties_on_user_id"
  end

  create_table "referrings", id: { type: :serial, comment: "ID" }, comment: "参照", force: :cascade do |t|
    t.integer "bib_id", comment: "参考文献ID"
    t.integer "referable_id", comment: "参照元ID"
    t.string "referable_type", limit: 255, comment: "参照元種別"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.index ["bib_id", "referable_id", "referable_type"], name: "index_referrings_on_bib_id_and_referable_id_and_referable_type", unique: true
    t.index ["bib_id"], name: "index_referrings_on_bib_id"
    t.index ["referable_id"], name: "index_referrings_on_referable_id"
  end

  create_table "search_columns", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.string "datum_type", limit: 255, comment: "モデル種別"
    t.string "name", limit: 255, comment: "カラム名"
    t.string "display_name", limit: 255, comment: "表示名"
    t.integer "display_order", comment: "表示順"
    t.integer "display_type", comment: "表示種別"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_search_columns_on_user_id"
  end

  create_table "specimen_custom_attributes", id: { type: :serial, comment: "ID" }, comment: "標本別カスタム属性", force: :cascade do |t|
    t.integer "specimen_id", comment: "標本ID"
    t.integer "custom_attribute_id", comment: "カスタム属性ID"
    t.string "value", limit: 255, comment: "値"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.index ["custom_attribute_id"], name: "index_specimen_custom_attributes_on_custom_attribute_id"
    t.index ["specimen_id"], name: "index_specimen_custom_attributes_on_specimen_id"
  end

  create_table "specimen_quantities", id: :serial, comment: "試料量", force: :cascade do |t|
    t.integer "specimen_id", comment: "標本ID"
    t.integer "divide_id"
    t.float "quantity", comment: "数量"
    t.string "quantity_unit", limit: 255, comment: "数量単位"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["divide_id"], name: "index_specimen_quantities_on_divide_id"
    t.index ["specimen_id"], name: "index_specimen_quantities_on_specimen_id"
  end

  create_table "specimen_surfaces", id: :serial, force: :cascade do |t|
    t.integer "specimen_id"
    t.integer "surface_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["specimen_id"], name: "index_specimen_surfaces_on_specimen_id"
    t.index ["surface_id"], name: "index_specimen_surfaces_on_surface_id"
  end

  create_table "specimens", id: { type: :serial, comment: "ID" }, comment: "標本", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.string "specimen_type", limit: 255, comment: "標本種別"
    t.text "description", comment: "説明"
    t.integer "parent_id", comment: "親標本ID"
    t.integer "place_id", comment: "場所ID"
    t.integer "box_id", comment: "保管場所ID"
    t.integer "physical_form_id", comment: "形状ID"
    t.integer "classification_id", comment: "分類ID"
    t.float "quantity", comment: "数量"
    t.string "quantity_unit", limit: 255, comment: "数量単位"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.string "igsn", limit: 9, comment: "IGSN"
    t.float "age_min", comment: "年代（最小）"
    t.float "age_max", comment: "年代（最大）"
    t.string "age_unit", limit: 255, comment: "年代単位"
    t.string "size", limit: 255, comment: "サイズ"
    t.string "size_unit", limit: 255, comment: "サイズ単位"
    t.datetime "collected_at", comment: "採取日時"
    t.string "collection_date_precision", limit: 255, comment: "採取日時精度"
    t.string "collector", limit: 255, comment: "採取者"
    t.string "collector_detail", limit: 255, comment: "採取詳細情報"
    t.boolean "fixed_in_box", default: false, null: false, comment: "固定格納フラグ"
    t.bigint "abs_age", comment: "絶対年代"
    t.datetime "collected_end_at", comment: "採取終了日時"
    t.index ["classification_id"], name: "index_specimens_on_classification_id"
    t.index ["parent_id"], name: "index_specimens_on_parent_id"
    t.index ["physical_form_id"], name: "index_specimens_on_physical_form_id"
  end

  create_table "spots", id: { type: :serial, comment: "ID" }, comment: "分析点", force: :cascade do |t|
    t.integer "attachment_file_id", comment: "添付ファイルID"
    t.string "name", limit: 255, comment: "名称"
    t.text "description", comment: "説明"
    t.float "spot_x", comment: "X座標"
    t.float "spot_y", comment: "Y座標"
    t.string "target_uid", limit: 255, comment: "対象UID"
    t.float "radius_in_percent", comment: "半径（％）"
    t.string "stroke_color", limit: 255, comment: "線色"
    t.float "stroke_width", comment: "線幅"
    t.string "fill_color", limit: 255, comment: "塗り潰し色"
    t.float "opacity", comment: "透明度"
    t.boolean "with_cross", comment: "クロス表示フラグ"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.integer "surface_id", comment: "SurfaceID"
    t.float "world_x", comment: "ワールドX座標"
    t.float "world_y", comment: "ワールドY座標"
    t.float "radius_in_um", comment: "半径 micro meter"
    t.index ["attachment_file_id"], name: "index_spots_on_attachment_file_id"
    t.index ["surface_id"], name: "index_spots_on_surface_id"
  end

  create_table "surface_images", id: :serial, force: :cascade do |t|
    t.integer "surface_id"
    t.integer "image_id"
    t.integer "position"
    t.boolean "wall"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "surface_layer_id", comment: "レイヤID"
    t.float "left"
    t.float "right"
    t.float "upper"
    t.float "bottom"
    t.string "data_file_name", limit: 255
    t.string "data_content_type", limit: 255
    t.integer "data_file_size"
    t.datetime "data_updated_at"
    t.index ["surface_layer_id"], name: "index_surface_images_on_surface_layer_id"
  end

  create_table "surface_layers", id: :serial, force: :cascade do |t|
    t.integer "surface_id", null: false, comment: "SurfaceID"
    t.string "name", limit: 255, null: false, comment: "レイヤ名"
    t.integer "opacity", default: 100, null: false, comment: "不透明度"
    t.integer "priority", null: false, comment: "優先順位"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "max_zoom_level"
    t.boolean "visible", default: true, null: false
    t.string "color_scale", limit: 255
    t.float "display_min"
    t.float "display_max"
    t.boolean "wall", default: false, null: false
    t.boolean "tiled", default: false, null: false
    t.index ["surface_id", "name"], name: "index_surface_layers_on_surface_id_and_name", unique: true
    t.index ["surface_id"], name: "index_surface_layers_on_surface_id"
  end

  create_table "surfaces", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "globe", default: false, null: false, comment: "地球表面フラグ"
    t.float "center_x"
    t.float "center_y"
    t.float "width"
    t.float "height"
  end

  create_table "table_analyses", id: { type: :serial, comment: "ID" }, comment: "表内分析情報", force: :cascade do |t|
    t.integer "table_id", comment: "表ID"
    t.integer "specimen_id", comment: "標本ID"
    t.integer "analysis_id", comment: "分析ID"
    t.integer "priority", comment: "優先度"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.index ["analysis_id"], name: "index_table_analyses_on_analysis_id"
    t.index ["specimen_id"], name: "index_table_analyses_on_specimen_id"
    t.index ["table_id"], name: "index_table_analyses_on_table_id"
  end

  create_table "table_specimens", id: { type: :serial, comment: "ID" }, comment: "表内標本情報", force: :cascade do |t|
    t.integer "table_id", comment: "表ID"
    t.integer "specimen_id", comment: "標本ID"
    t.integer "position", comment: "表示位置"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.index ["specimen_id"], name: "index_table_specimens_on_specimen_id"
    t.index ["table_id"], name: "index_table_specimens_on_table_id"
  end

  create_table "tables", id: { type: :serial, comment: "ID" }, comment: "表", force: :cascade do |t|
    t.integer "bib_id", comment: "参考文献ID"
    t.integer "measurement_category_id", comment: "測定種別ID"
    t.text "caption", comment: "表題"
    t.boolean "with_average", comment: "平均値表示フラグ"
    t.boolean "with_place", comment: "場所表示フラグ"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.boolean "with_age", comment: "年代表示フラグ"
    t.string "age_unit", limit: 255, comment: "年代単位"
    t.text "description", comment: "説明"
    t.integer "age_scale", comment: "有効精度"
    t.text "data"
    t.boolean "with_error", default: true, null: false
    t.index ["bib_id"], name: "index_tables_on_bib_id"
    t.index ["measurement_category_id"], name: "index_tables_on_measurement_category_id"
  end

  create_table "taggings", id: { type: :serial, comment: "ID" }, comment: "タグ付け", force: :cascade do |t|
    t.integer "tag_id", comment: "タグID"
    t.integer "taggable_id", comment: "タグ付け対象ID"
    t.string "taggable_type", limit: 255, comment: "タグ付け対象タイプ"
    t.integer "tagger_id", comment: "tagger_id"
    t.string "tagger_type", limit: 255, comment: "tagget_type"
    t.string "context", limit: 128, comment: "コンテキスト"
    t.datetime "created_at", comment: "作成日時"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: { type: :serial, comment: "ID" }, comment: "タグ", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "techniques", id: { type: :serial, comment: "ID" }, comment: "分析手法", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
  end

  create_table "units", id: { type: :serial, comment: "ID" }, comment: "単位", force: :cascade do |t|
    t.string "name", limit: 255, comment: "名称"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.float "conversion", null: false, comment: "変換"
    t.string "html", limit: 10, null: false, comment: "HTML表記"
    t.string "text", limit: 10, null: false, comment: "テキスト"
  end

  create_table "users", id: { type: :serial, comment: "ID" }, comment: "ユーザ", force: :cascade do |t|
    t.string "email", limit: 255, comment: "Eメールアドレス"
    t.string "encrypted_password", limit: 255, default: "", null: false, comment: "暗号化パスワード"
    t.string "reset_password_token", limit: 255, comment: "パスワードリセット"
    t.datetime "reset_password_sent_at", comment: "リセットパスワード送信日時"
    t.datetime "remember_created_at", comment: "ログイン状態保持作成日時"
    t.integer "sign_in_count", default: 0, null: false, comment: "サインイン回数"
    t.datetime "current_sign_in_at", comment: "今回サインイン日時"
    t.datetime "last_sign_in_at", comment: "前回サインイン日時"
    t.string "current_sign_in_ip", limit: 255, comment: "今回サインインIPアドレス"
    t.string "last_sign_in_ip", limit: 255, comment: "前回サインインIPアドレス"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "更新日時"
    t.boolean "administrator", default: false, null: false, comment: "管理者フラグ"
    t.string "family_name", limit: 255, comment: "姓"
    t.string "first_name", limit: 255, comment: "名"
    t.text "description", comment: "説明"
    t.string "username", limit: 255, null: false, comment: "ユーザ名"
    t.integer "box_id", comment: "保管場所ID"
    t.string "api_key", limit: 255, comment: "APIキー"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
