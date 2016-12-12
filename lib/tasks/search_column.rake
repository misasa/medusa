namespace :search_column do
  desc "Create search columns for each user."
  task create: :environment do
    ActiveRecord::Base.transaction do
      SearchColumn.destroy_all
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 1, display_type: SearchColumn::DisplayType::ALWAYS, name: "status", display_name: "")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 2, display_type: SearchColumn::DisplayType::ALWAYS, name: "name", display_name: "name")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 3, display_type: SearchColumn::DisplayType::ALWAYS, name: "igsn", display_name: "IGSN")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 4, display_type: SearchColumn::DisplayType::ALWAYS, name: "parent", display_name: "parent")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 5, display_type: SearchColumn::DisplayType::EXPAND, name: "box", display_name: "box")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 6, display_type: SearchColumn::DisplayType::ALWAYS, name: "physical_form", display_name: "physical-form")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 7, display_type: SearchColumn::DisplayType::ALWAYS, name: "classification", display_name: "classification")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 8, display_type: SearchColumn::DisplayType::EXPAND, name: "tags", display_name: "tags")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 9, display_type: SearchColumn::DisplayType::EXPAND, name: "age", display_name: "age")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 10, display_type: SearchColumn::DisplayType::EXPAND, name: "user", display_name: "owner")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 11, display_type: SearchColumn::DisplayType::ALWAYS, name: "group", display_name: "group")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 12, display_type: SearchColumn::DisplayType::EXPAND, name: "published", display_name: "published")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 13, display_type: SearchColumn::DisplayType::EXPAND, name: "published_at", display_name: "published-at")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 14, display_type: SearchColumn::DisplayType::ALWAYS, name: "updated_at", display_name: "updated-at")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 15, display_type: SearchColumn::DisplayType::EXPAND, name: "created_at", display_name: "created-at")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 16, display_type: SearchColumn::DisplayType::NONE, name: "specimen_type", display_name: "specimen-type")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 17, display_type: SearchColumn::DisplayType::NONE, name: "description", display_name: "description")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 18, display_type: SearchColumn::DisplayType::NONE, name: "place", display_name: "place")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 19, display_type: SearchColumn::DisplayType::NONE, name: "quantity", display_name: "quantity")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 20, display_type: SearchColumn::DisplayType::NONE, name: "quantity_unit", display_name: "quantity-unit")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 21, display_type: SearchColumn::DisplayType::NONE, name: "age_min", display_name: "age-min")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 22, display_type: SearchColumn::DisplayType::NONE, name: "age_max", display_name: "age-max")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 23, display_type: SearchColumn::DisplayType::NONE, name: "age_unit", display_name: "age-unit")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 24, display_type: SearchColumn::DisplayType::NONE, name: "size", display_name: "size")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 25, display_type: SearchColumn::DisplayType::NONE, name: "size_unit", display_name: "size-unit")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 26, display_type: SearchColumn::DisplayType::NONE, name: "collected_at", display_name: "collected-at")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 27, display_type: SearchColumn::DisplayType::NONE, name: "collection_date_precision", display_name: "collection-date-precision")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 28, display_type: SearchColumn::DisplayType::NONE, name: "collector", display_name: "collector")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 29, display_type: SearchColumn::DisplayType::NONE, name: "collector_detail", display_name: "collector-detail")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 30, display_type: SearchColumn::DisplayType::NONE, name: "disposed", display_name: "disposed")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 31, display_type: SearchColumn::DisplayType::NONE, name: "disposed_at", display_name: "disposed-at")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 32, display_type: SearchColumn::DisplayType::NONE, name: "lost", display_name: "lost")
      SearchColumn.create(user_id: SearchColumn::MASTER_USER_ID, datum_type: "Specimen", display_order: 33, display_type: SearchColumn::DisplayType::NONE, name: "lost_at", display_name: "lost-at")
      User.all.each do |user|
        user.send(:create_search_columns)
      end
    end
  end
end
