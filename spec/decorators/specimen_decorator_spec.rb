require 'spec_helper'
include ActionDispatch::TestProcess

describe SpecimenDecorator do
  let(:user){FactoryBot.create(:user)}
  let(:obj){FactoryBot.create(:specimen).decorate}
  let(:box){FactoryBot.create(:box)}
  before{User.current = user}

  describe "icon" do
    subject { SpecimenDecorator.icon }
    it { expect(subject).to eq ("<span class=\"fas fa-cloud\"></span>") }
  end

  describe "search_name" do
    let(:column) { FactoryBot.create(:search_column, name: name) }
    subject { SpecimenDecorator.search_name(column) }
    context "column is name" do
      let(:name) { "name" }
      it { expect(subject).to eq "name" }
    end
    context "column is name" do
      let(:name) { "published" }
      it { expect(subject).to eq "record_property_published" }
    end
    context "column is age" do
      let(:name) { "age" }
      it { expect(subject).to eq nil }
    end
  end

  describe "search_form" do
    let(:column) { FactoryBot.create(:search_column, name: name) }
    let(:f) do
      form = nil
      h.search_form_for(Specimen.search){|f| form = f }
      form
    end
    subject { SpecimenDecorator.search_form(f, column) }
    context "column is status" do
      let(:name) { "status" }
      it { expect(subject).to eq nil }
    end
    context "column is name" do
      let(:name) { "name" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[name_cont]\" id=\"q_name_cont\" />"
        )
      end
    end
    context "column is igsn" do
      let(:name) { "igsn" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[igsn_cont]\" id=\"q_igsn_cont\" />"
        )
      end
    end
    context "column is parent" do
      let(:name) { "parent" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[parent_name_cont]\" id=\"q_parent_name_cont\" />"
        )
      end
    end
    context "column is box" do
      let(:name) { "box" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[box_name_cont]\" id=\"q_box_name_cont\" />"
        )
      end
    end
    context "column is physical_form" do
      let(:name) { "physical_form" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[physical_form_name_cont]\" id=\"q_physical_form_name_cont\" />"
        )
      end
    end
    context "column is classification" do
      let(:name) { "classification" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[classification_full_name_cont]\" id=\"q_classification_full_name_cont\" />"
        )
      end
    end
    context "column is tags" do
      let(:name) { "tags" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"q[tags_name_eq]\" id=\"q_tags_name_eq\"><option value=\"\" label=\" \"></option>\n"\
          + "</select>"
        )
      end
    end
    context "column is age" do
      let(:name) { "age" }
      it { expect(subject).to eq nil }
    end
    context "column is user" do
      let(:name) { "user" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[user_username_cont]\" id=\"q_user_username_cont\" />"
        )
      end
    end
    context "column is group" do
      let(:name) { "group" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[group_name_cont]\" id=\"q_group_name_cont\" />"
        )
      end
    end
    context "column is published" do
      let(:name) { "published" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"q[record_property_published_eq]\" id=\"q_record_property_published_eq\"><option value=\"\" label=\" \"></option>\n"\
          + "<option value=\"true\">true</option>\n"\
          + "<option value=\"false\">false</option></select>"
        )
      end
    end
    context "column is published_at" do
      let(:name) { "published_at" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[record_property_published_at_gteq]\" id=\"q_record_property_published_at_gteq\" />"\
          + "<input placeholder=\"to:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[record_property_published_at_lteq_end_of_day]\" id=\"q_record_property_published_at_lteq_end_of_day\" />"
        )
      end
    end
    context "column is updated_at" do
      let(:name) { "updated_at" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[updated_at_gteq]\" id=\"q_updated_at_gteq\" />"\
          + "<input placeholder=\"to:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[updated_at_lteq_end_of_day]\" id=\"q_updated_at_lteq_end_of_day\" />"
        )
      end
    end
    context "column is created_at" do
      let(:name) { "created_at" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[created_at_gteq]\" id=\"q_created_at_gteq\" />"\
          + "<input placeholder=\"to:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[created_at_lteq_end_of_day]\" id=\"q_created_at_lteq_end_of_day\" />"
        )
      end
    end
    context "column is specimen_type" do
      let(:name) { "specimen_type" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[specimen_type_cont]\" id=\"q_specimen_type_cont\" />"
        )
      end
    end
    context "column is description" do
      let(:name) { "description" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[description_cont]\" id=\"q_description_cont\" />"
        )
      end
    end
    context "column is place" do
      let(:name) { "place" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[place_name_cont]\" id=\"q_place_name_cont\" />"
        )
      end
    end
    context "column is quantity" do
      let(:name) { "quantity" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[quantity_gteq]\" id=\"q_quantity_gteq\" />"\
          + "<input placeholder=\"to:\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[quantity_lteq]\" id=\"q_quantity_lteq\" />"
        )
      end
    end
    context "column is quantity_unit" do
      let(:name) { "quantity_unit" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[quantity_unit_cont]\" id=\"q_quantity_unit_cont\" />"
        )
      end
    end
    context "column is age_min" do
      let(:name) { "age_min" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[age_min_gteq]\" id=\"q_age_min_gteq\" />"\
          + "<input placeholder=\"to:\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[age_min_lteq]\" id=\"q_age_min_lteq\" />"
        )
      end
    end
    context "column is age_max" do
      let(:name) { "age_max" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[age_max_gteq]\" id=\"q_age_max_gteq\" />"\
          + "<input placeholder=\"to:\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[age_max_lteq]\" id=\"q_age_max_lteq\" />"
        )
      end
    end
    context "column is age_unit" do
      let(:name) { "age_unit" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[age_unit_cont]\" id=\"q_age_unit_cont\" />"
        )
      end
    end
    context "column is size" do
      let(:name) { "size" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[size_cont]\" id=\"q_size_cont\" />"
        )
      end
    end
    context "column is size_unit" do
      let(:name) { "size_unit" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[size_unit_cont]\" id=\"q_size_unit_cont\" />"
        )
      end
    end
    context "column is collected_at" do
      let(:name) { "collected_at" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[collected_at_gteq]\" id=\"q_collected_at_gteq\" />"\
          + "<input placeholder=\"to:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[collected_at_lteq_end_of_day]\" id=\"q_collected_at_lteq_end_of_day\" />"
        )
      end
    end
    context "column is collection_date_precision" do
      let(:name) { "collection_date_precision" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[collection_date_precision_cont]\" id=\"q_collection_date_precision_cont\" />"
        )
      end
    end
    context "column is collector" do
      let(:name) { "collector" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[collector_cont]\" id=\"q_collector_cont\" />"
        )
      end
    end
    context "column is collector_detail" do
      let(:name) { "collector_detail" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"q[collector_detail_cont]\" id=\"q_collector_detail_cont\" />"
        )
      end
    end
    context "column is disposed" do
      let(:name) { "disposed" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"q[record_property_disposed_eq]\" id=\"q_record_property_disposed_eq\"><option value=\"\" label=\" \"></option>\n"\
          + "<option value=\"true\">true</option>\n"\
          + "<option value=\"false\">false</option></select>"
        )
      end
    end
    context "column is disposed_at" do
      let(:name) { "disposed_at" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[record_property_disposed_at_gteq]\" id=\"q_record_property_disposed_at_gteq\" />"\
          + "<input placeholder=\"to:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[record_property_disposed_at_lteq_end_of_day]\" id=\"q_record_property_disposed_at_lteq_end_of_day\" />"
        )
      end
    end
    context "column is lost" do
      let(:name) { "lost" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"q[record_property_lost_eq]\" id=\"q_record_property_lost_eq\"><option value=\"\" label=\" \"></option>\n"\
          + "<option value=\"true\">true</option>\n"\
          + "<option value=\"false\">false</option></select>"
        )
      end
    end
    context "column is lost_at" do
      let(:name) { "lost_at" }
      it do
        expect(subject).to eq(
          "<input placeholder=\"from:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[record_property_lost_at_gteq]\" id=\"q_record_property_lost_at_gteq\" />"\
          + "<input placeholder=\"to:\" value=\"\" class=\"form-control input-sm datepicker\" style=\"min-width: 60px;\" type=\"text\" name=\"q[record_property_lost_at_lteq_end_of_day]\" id=\"q_record_property_lost_at_lteq_end_of_day\" />"
        )
      end
    end
  end

  describe "create_form" do
    let(:column) { FactoryBot.create(:search_column, name: name) }
    let(:f) do
      form = nil
      h.form_for(Specimen.new){|f| form = f }
      form
    end
    subject { SpecimenDecorator.create_form(f, column, page_type) }
    context "column is status" do
      let(:name) { "status" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is name" do
      let(:name) { "name" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[name]\" id=\"specimen_name\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is igsn" do
      let(:name) { "igsn" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is parent" do
      let(:name) { "parent" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<div class=\"input-group\">"\
            + "<input id=\"specimen_parent_global_id\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[parent_global_id]\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-toggle=\"modal\" data-target=\"#search-modal\" data-input=\"#specimen_parent_global_id\" href=\"/specimens.modal?per_page=10\">"\
            + "<span class=\"fas fa-search\"></span>"\
            + "</a>"\
            + "</span>"\
            + "</div>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<div class=\"input-group\">"\
            + "<input id=\"specimen_parent_global_id\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[parent_global_id]\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-toggle=\"modal\" data-target=\"#search-modal\" data-input=\"#specimen_parent_global_id\" href=\"/specimens.modal?per_page=10\">"\
            + "<span class=\"fas fa-search\"></span>"\
            + "</a>"\
            + "</span>"\
            + "</div>"
          )
        end
      end
    end
    context "column is box" do
      let(:name) { "box" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<div class=\"input-group\">"\
            + "<input id=\"specimen_box_global_id\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[box_global_id]\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-toggle=\"modal\" data-target=\"#search-modal\" data-input=\"#specimen_box_global_id\" href=\"/boxes.modal?per_page=10\">"\
            + "<span class=\"fas fa-search\"></span>"\
            + "</a>"\
            + "</span>"\
            + "</div>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<div class=\"input-group\">"\
            + "<input id=\"specimen_box_global_id\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[box_global_id]\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-toggle=\"modal\" data-target=\"#search-modal\" data-input=\"#specimen_box_global_id\" href=\"/boxes.modal?per_page=10\">"\
            + "<span class=\"fas fa-search\"></span>"\
            + "</a>"\
            + "</span>"\
            + "</div>"
          )
        end
      end
    end
    context "column is physical_form" do
      let(:name) { "physical_form" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[physical_form_id]\" id=\"specimen_physical_form_id\"><option value=\"\" label=\" \"></option>\n"\
            + "</select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[physical_form_id]\" id=\"specimen_physical_form_id\"><option value=\"\" label=\" \"></option>\n"\
            + "</select>"
          )
        end
      end
    end
    context "column is classification" do
      let(:name) { "classification" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[classification_id]\" id=\"specimen_classification_id\"><option value=\"\" label=\" \"></option>\n"\
            + "</select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[classification_id]\" id=\"specimen_classification_id\"><option value=\"\" label=\" \"></option>\n"\
            + "</select>"
          )
        end
      end
    end
    context "column is tags" do
      let(:name) { "tags" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" value=\"\" name=\"specimen[tag_list]\" id=\"specimen_tag_list\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" value=\"\" name=\"specimen[tag_list]\" id=\"specimen_tag_list\" />"
          )
        end
      end
    end
    context "column is age" do
      let(:name) { "age" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is user" do
      let(:name) { "user" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<label for=\"specimen_user\">user</label>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[user_id]\" id=\"specimen_user_id\"><option value=\"\" label=\" \"></option>\n"\
            + "<option value=\"#{user.id}\">user</option></select>"
          )
        end
      end
    end
    context "column is group" do
      let(:name) { "group" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[group_id]\" id=\"specimen_group_id\"><option value=\"\" label=\" \"></option>\n"\
            + "</select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[group_id]\" id=\"specimen_group_id\"><option value=\"\" label=\" \"></option>\n"\
            + "</select>"
          )
        end
      end
    end
    context "column is published" do
      let(:name) { "published" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[published]\" id=\"specimen_published\"><option value=\"\" label=\" \"></option>\n"\
            + "<option value=\"true\">true</option>\n"\
            + "<option value=\"false\">false</option></select>"
          )
        end
      end
    end
    context "column is published_at" do
      let(:name) { "published_at" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is updated_at" do
      let(:name) { "updated_at" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is created_at" do
      let(:name) { "created_at" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is specimen_type" do
      let(:name) { "specimen_type" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[specimen_type]\" id=\"specimen_specimen_type\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[specimen_type]\" id=\"specimen_specimen_type\" />"
          )
        end
      end
    end
    context "column is description" do
      let(:name) { "description" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[description]\" id=\"specimen_description\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[description]\" id=\"specimen_description\" />"
          )
        end
      end
    end
    context "column is place" do
      let(:name) { "place" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<div class=\"input-group\">"\
            + "<input id=\"specimen_place_global_id\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[place_global_id]\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-toggle=\"modal\" data-target=\"#search-modal\" data-input=\"#specimen_place_global_id\" href=\"/places.modal?per_page=10\">"\
            + "<span class=\"fas fa-search\"></span>"\
            + "</a>"\
            + "</span>"\
            + "</div>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<div class=\"input-group\">"\
            + "<input id=\"specimen_place_global_id\" class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[place_global_id]\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-toggle=\"modal\" data-target=\"#search-modal\" data-input=\"#specimen_place_global_id\" href=\"/places.modal?per_page=10\">"\
            + "<span class=\"fas fa-search\"></span>"\
            + "</a>"\
            + "</span>"\
            + "</div>"
          )
        end
      end
    end
    context "column is quantity" do
      let(:name) { "quantity" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[quantity]\" id=\"specimen_quantity\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[quantity]\" id=\"specimen_quantity\" />"
          )
        end
      end
    end
    context "column is quantity_unit" do
      let(:name) { "quantity_unit" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[quantity_unit]\" id=\"specimen_quantity_unit\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[quantity_unit]\" id=\"specimen_quantity_unit\" />"
          )
        end
      end
    end
    context "column is age_min" do
      let(:name) { "age_min" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[age_min]\" id=\"specimen_age_min\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[age_min]\" id=\"specimen_age_min\" />"
          )
        end
      end
    end
    context "column is age_max" do
      let(:name) { "age_max" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[age_max]\" id=\"specimen_age_max\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[age_max]\" id=\"specimen_age_max\" />"
          )
        end
      end
    end
    context "column is age_unit" do
      let(:name) { "age_unit" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[age_unit]\" id=\"specimen_age_unit\"><option value=\"\" label=\" \"></option>\n"\
            + "<option value=\"a\">a</option>\n"\
            + "<option value=\"ka\">ka</option>\n"\
            + "<option value=\"Ma\">Ma</option>\n"\
            + "<option value=\"Ga\">Ga</option></select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[age_unit]\" id=\"specimen_age_unit\"><option value=\"\" label=\" \"></option>\n"\
            + "<option value=\"a\">a</option>\n"\
            + "<option value=\"ka\">ka</option>\n"\
            + "<option value=\"Ma\">Ma</option>\n"\
            + "<option value=\"Ga\">Ga</option></select>"
          )
        end
      end
    end
    context "column is size" do
      let(:name) { "size" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[size]\" id=\"specimen_size\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[size]\" id=\"specimen_size\" />"
          )
        end
      end
    end
    context "column is size_unit" do
      let(:name) { "size_unit" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[size_unit]\" id=\"specimen_size_unit\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[size_unit]\" id=\"specimen_size_unit\" />"
          )
        end
      end
    end
    context "column is collected_at" do
      let(:name) { "collected_at" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collected_at]\" id=\"specimen_collected_at\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collected_at]\" id=\"specimen_collected_at\" />"
          )
        end
      end
    end
    context "column is collection_date_precision" do
      let(:name) { "collection_date_precision" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collection_date_precision]\" id=\"specimen_collection_date_precision\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collection_date_precision]\" id=\"specimen_collection_date_precision\" />"
          )
        end
      end
    end
    context "column is collector" do
      let(:name) { "collector" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collector]\" id=\"specimen_collector\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collector]\" id=\"specimen_collector\" />"
          )
        end
      end
    end
    context "column is collector_detail" do
      let(:name) { "collector_detail" }
      context "index" do
        let(:page_type) { :index }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collector_detail]\" id=\"specimen_collector_detail\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" style=\"min-width: 60px;\" type=\"text\" name=\"specimen[collector_detail]\" id=\"specimen_collector_detail\" />"
          )
        end
      end
    end
    context "column is disposed" do
      let(:name) { "disposed" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[disposed]\" id=\"specimen_disposed\"><option value=\"\" label=\" \"></option>\n"\
            + "<option value=\"true\">true</option>\n"\
            + "<option value=\"false\">false</option></select>"
          )
        end
      end
    end
    context "column is disposed_at" do
      let(:name) { "disposed_at" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
    context "column is lost" do
      let(:name) { "lost" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" style=\"min-width: 60px;\" name=\"specimen[lost]\" id=\"specimen_lost\"><option value=\"\" label=\" \"></option>\n"\
            + "<option value=\"true\">true</option>\n"\
            + "<option value=\"false\">false</option></select>"
          )
        end
      end
    end
    context "column is lost_at" do
      let(:name) { "lost_at" }
      context "index" do
        let(:page_type) { :index }
        it { expect(subject).to eq nil }
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it { expect(subject).to eq nil }
      end
    end
  end

  describe "content" do
    let(:parent) { FactoryBot.create(:specimen, name: "parent1") }
    let(:box) { FactoryBot.create(:box, name: "box1") }
    let(:place) { FactoryBot.create(:place, name: "place1") }
    let(:physical_form) { FactoryBot.create(:physical_form, name: "physical_form1") }
    let(:parent_classification) { FactoryBot.create(:classification, name: "classification1") }
    let(:classification) { FactoryBot.create(:classification, name: "classification2", parent: parent_classification) }
    let(:group) { FactoryBot.create(:group, name: "group1") }
    let(:time) { "2016-11-01 10:11:12".to_time }
    let(:specimen) do
      FactoryBot.create(:specimen,
        name: "specimen1",
        parent: parent,
        box: box,
        place: place,
        physical_form: physical_form,
        classification: classification,
        created_at: time,
        updated_at: time,
        collected_at: time)
    end
    before do
      specimen.published = true
      specimen.disposed = true
      specimen.lost = true
      specimen.save!
      specimen.record_property.group = group
      specimen.record_property.published_at = time
      specimen.record_property.disposed_at = time
      specimen.record_property.lost_at = time
      specimen.updated_at = time
      specimen.save!
    end
    subject { specimen.decorate.content(column_name) }
    describe "name_link" do
      let(:column_name){ "name" }
      it do
        expect(subject).to eq("<a class=\" ghost\" href=\"/specimens/#{specimen.id}\"><span class=\"\"><span class=\"fas fa-cloud\"></span></span> specimen1 <span class=\"label label-danger\">pub</span></a>")
        #expect(subject).to eq("<a class=\" ghost\" href=\"/specimens/#{specimen.id}\">specimen1</a>")
      end
    end

    describe "parent_link" do
      let(:column_name){ "parent" }
      it do
        expect(subject).to eq(
          "<a class=\"\" href=\"/specimens/#{parent.id}\">parent1</a>"
        )
      end
    end

    describe "place_link" do
      let(:column_name){ "place" }
      it do
        expect(subject).to eq(
          "<a href=\"/places/#{place.id}\">place1</a>"
        )
      end
    end

    describe "box_link" do
      let(:column_name){ "box" }
      it do
        expect(subject).to eq(
          "<a href=\"/boxes/#{box.id}\">box1</a>"
        )
      end
    end

    describe "physical_form_name" do
      let(:column_name){ "physical_form" }
      it { expect(subject).to eq "physical_form1" }
    end

    describe "classification_full_name" do
      let(:column_name) { "classification" }
      it { expect(subject).to eq "classification1:classification2" }
    end

    describe "age_raw" do

    end

    describe "user_name" do
      let(:column_name) { "user" }
      it { expect(subject).to eq "user" }
    end

    describe "group_name" do
      let(:column_name) { "group" }
      it { expect(subject).to eq "group1" }
    end

    describe "format_created_at" do
      let(:column_name) { "created_at" }
      it { expect(subject.to_s).to eq "2016-11-01" }
    end

    describe "format_updated_at" do
      let(:column_name) { "updated_at" }
      it { expect(subject.to_s).to eq "2016-11-01" }
    end

    describe "format_collected_at" do
      let(:column_name) { "collected_at" }
      it { expect(subject.to_s).to eq "2016-11-01" }
    end

    describe "format_published_at" do
      let(:column_name) { "published_at" }
      it { expect(subject.to_s).to eq "2016-11-01" }
    end

    describe "format_disposed_at" do
      let(:column_name) { "disposed_at" }
      it { expect(subject.to_s).to eq "2016-11-01" }
    end

    describe "format_lost_at" do
      let(:column_name) { "lost_at" }
      it { expect(subject.to_s).to eq "2016-11-01" }
    end
  end

  describe ".summary_of_analysis" do
    subject { obj.summary_of_analysis }
    let(:analysis_1){FactoryBot.create(:analysis)}
    let(:item_1){FactoryBot.create(:measurement_item)}
    let(:chemistry_1){FactoryBot.create(:chemistry, :analysis_id => analysis_1.id, :measurement_item_id => item_1.id)}
    before {
      allow(obj.h).to receive(:can?).and_return(true)
      analysis_1.specimen = obj
      analysis_1.save
    }
    it { expect(subject).to include("<a href=\"#specimen-analyses-#{obj.id}\" data-toggle=\"collapse\" class=\"collapse-active\"><span class=\"badge\">1</span></a>") }
  end

  describe ".name_with_id" do
    subject{obj.name_with_id}
    it{expect(subject).to include(obj.name)}
    it{expect(subject).to include(obj.global_id)}
    it{expect(subject).to include("<span class=\"fas fa-cloud\"></span>")}
  end

  describe ".path" do
    let(:me){"<span class=\"\"><span class=\"fas fa-cloud\"></span></span>#{obj.name}"}
    subject{obj.path}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    context "box is nil" do
      before{obj.box = nil}
      it{expect(subject).to eq "<span class=\"\"><span class=\"\"><span class=\"fas fa-cloud\"></span></span>#{obj.name}</span>"}
    end
    context "box is not nil" do
      before{obj.box = box}
      it{expect(subject).to include("<span class=\"fas fa-folder\"></span>")}
      it{expect(subject).to include("<a href=\"/boxes/#{box.id}\">#{box.name}</a>")}
      it{expect(subject).to include(me)}
    end
  end

  describe ".primary_picture" do
    let(:attachment_file){ FactoryBot.create(:attachment_file) }
    let(:picture) { obj.primary_picture(width: width, height: height) }
    let(:capybara) { Capybara.string(picture) }
    let(:body) { capybara.find("body") }
    let(:img) { body.find("img") }
    let(:width) { 250 }
    let(:height) { 250 }
    before { obj.attachment_files = [attachment_file] }
    it { expect(body).to have_css("img") }
    it { expect(img["src"]).to eq attachment_file.path }
    context "width rate greater than height rate" do
      let(:width) { 100 }
      it { expect(img["width"]).to eq width.to_s }
      it { expect(img["height"]).to be_blank }
    end
    context "width rate eq height rate" do
      it { expect(img["width"]).to eq width.to_s }
      it { expect(img["height"]).to be_blank }
    end
    context "width rate less than height rate" do
      let(:height) { 100 }
      it { expect(img["width"]).to be_blank }
      it { expect(img["height"]).to eq height.to_s }
    end
  end

  describe ".family_tree" do
    subject{obj.family_tree}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    it{expect(subject).to match("<div class=\"tree-node\" data-depth=\"1\">.*</div>")}
    it{expect(subject).to include("<span class=\"fas fa-cloud\"></span>")}
    it{expect(subject).to match("<a href=\"/specimens/#{obj.id}\">.*</a>")}
    it{expect(subject).to include("<strong class=\"text-primary bg-primary\">#{obj.name}</strong>")}
  end

  describe "tree_nodes" do
    let(:specimen) { FactoryBot.create(:specimen, name: "test_1") }
    let(:analysis) { FactoryBot.create(:analysis, name: "test_2") }
    let(:bib) { FactoryBot.create(:bib, name: "test_3") }
    let(:attachment_file) { FactoryBot.create(:attachment_file, name: "test_4", data_file_name: "test_4.jpg") }
    before do
      sign_in user
      obj.children << specimen
      obj.analyses << analysis
      obj.bibs << bib
      obj.attachment_files << attachment_file
    end
    subject { obj.tree_nodes(klass, 10) }
    context "klass is Analysis" do
      let(:klass) { Analysis }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"fas fa-chart-bar\"></span>"\
          + "<a href=\"/analyses/#{analysis.id}\">test_2</a>"\
          + "<a data-toggle=\"modal\" data-target=\"#show-modal\" href=\"/analyses/#{analysis.id}.modal\"><span class=\"badge\">0</span></a>"\
          + "</div>"\
          + "</div>"
        )
      end
    end
    context "klass is Bib" do
      let(:klass) { Bib }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"fas fa-book\"></span>"\
          + "<a href=\"/bibs/#{bib.id}\">test_3</a>"\
          + "</div>"\
          + "</div>"
        )
      end
    end
    context "klass is AttachmentFile" do
      let(:klass) { AttachmentFile }
      it do
        expect(subject).to eq(
          "<div class=\"collapse in\" id=\"tree-#{klass}-#{obj.record_property_id}\">"\
          + "<div class=\"tree-node\" data-depth=\"10\">"\
          + "<span class=\"fas fa-file\"></span>"\
          + "<a href=\"/attachment_files/#{attachment_file.id}\">test_4.jpg</a>"\
          + "</div>"\
          + "</div>"
        )
      end
    end
    context "other klass" do
      let(:klass) { Specimen }
      it { expect(subject).to eq("") }
    end
  end

  describe ".tree_node" do
    subject{obj.tree_node}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    let(:child){FactoryBot.create(:specimen)}
    let(:analysis){FactoryBot.create(:analysis)}
    let(:bib){FactoryBot.create(:bib)}
    let(:attachment_file){FactoryBot.create(:attachment_file)}
    it{expect(subject).to include("<span class=\"fas fa-cloud\"></span>")}
    it{expect(subject).to include("#{obj.name}")}
    before do
      obj.children << child
      obj.analyses << analysis
      obj.bibs << bib
      obj.attachment_files << attachment_file
    end
    it {expect(subject).to_not include("<span class=\"fas fa-cloud \"></span><span>#{obj.children.count}</span>") }
    it do
      expect(subject).to include(
        "<span class=\"\"><span class=\"fas fa-chart-bar\"></span></span>"\
        + "<a href=\"#tree-Analysis-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
        + "<span data-klass=\"Analysis\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.analyses.count}</span></a>"
      )
    end
    it do
      expect(subject).to include(
        "<span class=\"\"><span class=\"fas fa-book\"></span></span>"\
        + "<a href=\"#tree-Bib-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
        + "<span data-klass=\"Bib\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.bibs.count}</span></a>"
      )
    end
    it do
      expect(subject).to include(
        "<span class=\"\"><span class=\"fas fa-file\"></span></span>"\
        + "<a href=\"#tree-AttachmentFile-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
        + "<span data-klass=\"AttachmentFile\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.attachment_files.count}</span></a>"
      )
    end
    context "current" do
      subject{obj.tree_node(current: true)}
      it{expect(subject).to match("<strong class=\"text-primary bg-primary\">.*</strong>")}
    end
    context "not current" do
      subject{obj.tree_node(current: false)}
      it{expect(subject).not_to match("<strong>.*</strong>")}
    end
    context "current_type" do
      context "in_list_include" do
        subject{ obj.tree_node(current_type: true, in_list_include: true) }
        it do
          expect(subject).to include(
            "<span class=\"fa-active-color\"><span class=\"fas fa-cloud\"></span></span>"\
            + "<a href=\"#tree-Specimen-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"Specimen\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{obj.children.count}</span></a>"
          )
        end
        it { expect(subject).to include("<span class=\"fas fa-chart-bar\"></span><span>#{obj.analyses.count}</span>") }
        it { expect(subject).to include("<span class=\"fas fa-book\"></span><span>#{obj.bibs.count}</span>") }
        it { expect(subject).to include("<span class=\"fas fa-file\"></span><span>#{obj.attachment_files.count}</span>") }
      end
      context "not in_list_include" do
        subject{ obj.tree_node(current_type: true, in_list_include: false) }
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"fas fa-cloud\"></span></span>"\
            + "<a href=\"#tree-Specimen-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"Specimen\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.children.count}</span></a>"
          )
        end
        it { expect(subject).to include("<span class=\"fas fa-chart-bar\"></span><span>#{obj.analyses.count}</span>") }
        it { expect(subject).to include("<span class=\"fas fa-book\"></span><span>#{obj.bibs.count}</span>") }
        it { expect(subject).to include("<span class=\"fas fa-file\"></span><span>#{obj.attachment_files.count}</span>") }
      end
    end
    context "not current_type" do
      context "in_list_include" do
        subject{ obj.tree_node(current_type: false, in_list_include: true) }
        it{ expect(subject).to_not include("<span class=\"fas fa-cloud\"></span><span>#{obj.children.count}</span>") }
        it do
          expect(subject).to include(
            "<span class=\"fa-active-color\"><span class=\"fas fa-chart-bar\"></span></span>"\
            + "<a href=\"#tree-Analysis-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"Analysis\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{obj.analyses.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"fa-active-color\"><span class=\"fas fa-book\"></span></span>"\
            + "<a href=\"#tree-Bib-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"Bib\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{obj.bibs.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"fa-active-color\"><span class=\"fas fa-file\"></span></span>"\
            + "<a href=\"#tree-AttachmentFile-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"AttachmentFile\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{obj.attachment_files.count}</span></a>"
          )
        end
      end
      context "not in_list_include" do
        subject{ obj.tree_node(current_type: false, in_list_include: false) }
        it{ expect(subject).to_not include("<span class=\"fas fa-cloud\"></span><span>#{obj.children.count}</span>") }
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"fas fa-chart-bar\"></span></span>"\
            + "<a href=\"#tree-Analysis-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"Analysis\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.analyses.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"fas fa-book\"></span></span>"\
            + "<a href=\"#tree-Bib-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"Bib\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.bibs.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"fas fa-file\"></span></span>"\
            + "<a href=\"#tree-AttachmentFile-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
            + "<span data-klass=\"AttachmentFile\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{obj.attachment_files.count}</span></a>"
          )
        end
      end
    end
  end

  describe "children_count" do
    subject { obj.children_count }
    let(:icon) { "cloud" }
    let(:klass) { "Specimen" }
    let(:count) { obj.children.count }
    let(:child) { FactoryBot.create(:specimen) }
    context "count zero" do
      before { obj.children.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.children << child }
      context "current_type" do
        context "in_list_include" do
          subject { obj.children_count(true, true) }
          it do
            expect(subject).to eq(
              "<span class=\"fa-active-color\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.children_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
      context "not current_type" do
        subject { obj.children_count(false, false) }
        it { expect(subject).to be_blank }
      end
    end
  end

  describe "analyses_count" do
    subject { obj.analyses_count }
    let(:icon) { "stats" }
    let(:klass) { "Analysis" }
    let(:count) { obj.analyses.count }
    let(:analysis) { FactoryBot.create(:analysis) }
    context "count zero" do
      before { obj.analyses.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.analyses << analysis }
      context "current_type" do
        context "in_list_include" do
          subject { obj.analyses_count(true, true) }
          it { expect(subject).to eq("<span class=\"fas fa-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.analyses_count(true, false) }
          it { expect(subject).to eq("<span class=\"fas fa-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.analyses_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"fa-active-color\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.analyses_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
    end
  end

  describe "bibs_count" do
    subject { obj.bibs_count }
    let(:icon) { "book" }
    let(:klass) { "Bib" }
    let(:count) { obj.bibs.count }
    let(:bib) { FactoryBot.create(:bib) }
    context "count zero" do
      before { obj.bibs.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.bibs << bib }
      context "current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(true, true) }
          it { expect(subject).to eq("<span class=\"fas fa-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.bibs_count(true, false) }
          it { expect(subject).to eq("<span class=\"fas fa-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"fa-active-color\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.bibs_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
    end
  end

  describe "files_count" do
    subject { obj.files_count }
    let(:icon) { "file" }
    let(:klass) { "AttachmentFile" }
    let(:count) { obj.attachment_files.count }
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    context "count zero" do
      before { obj.attachment_files.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.attachment_files << attachment_file }
      context "current_type" do
        context "in_list_include" do
          subject { obj.files_count(true, true) }
          it { expect(subject).to eq("<span class=\"fas fa-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.files_count(true, false) }
          it { expect(subject).to eq("<span class=\"fas fa-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.files_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"fa-active-color\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge badge-active\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.files_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"fas fa-#{icon}\"></span></span>"\
              + "<a href=\"#tree-#{klass}-#{obj.record_property_id}\" data-toggle=\"collapse\" class=\"collapse-active\">"\
              + "<span data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\" class=\"badge\">#{count}</span></a>"
            )
          end
        end
      end
    end
  end

  describe ".to_tex" do
    subject{ obj.to_tex(alias_specimen) }
    before{ obj.children << child }
    let(:alias_specimen) { "specimen" }
    let(:child) { FactoryBot.create(:specimen, name: child_name) }
    let(:child_name) { "child_name" }
    it{ expect(subject).to include(obj.name) }
    it{ expect(subject).to include(obj.global_id) }
    it{ expect(subject).to include(child.name) }
    it{ expect(subject).to include(child.physical_form.name) }
    it{ expect(subject).to include(child.quantity.to_s) }
    it{ expect(subject).to include(child.global_id) }
    it{ expect(subject).to include(alias_specimen) }
  end

  describe "status_name" do
    subject { obj.status_name }
    context "normal" do
      before { obj.update(quantity: 0.5, quantity_unit: "mg") }
      it { expect(subject).to eq("") }
    end
    context "undetermined quantity" do
      before { obj.update(quantity: "", quantity_unit: "") }
      it { expect(subject).to eq("unknown") }
    end
    context "disappearance" do
      before { obj.update(quantity: "0", quantity_unit: "kg") }
      it { expect(subject).to eq("zero") }
    end
    context "disposal" do
      before { obj.record_property.update(disposed: true) }
      it { expect(subject).to eq("trash") }
    end
    context "loss" do
      before { obj.record_property.update(lost: true) }
      it { expect(subject).to eq("lost") }
    end
  end

  describe "status_icon" do
    subject { obj.status_icon }
    context "normal" do
      before { obj.update(quantity: 0.5, quantity_unit: "mg") }
      it {expect(subject).to eq("<span title=\"status:\" class=\"\"><span class=\"fas fa-\"></span></span>") }
    end
    context "undetermined quantity" do
      before { obj.update(quantity: "", quantity_unit: "") }
      it {expect(subject).to eq("<span title=\"status:unknown\" class=\"\"><span class=\"fas fa-question-circle\"></span></span>") }
    end
    context "disappearance" do
      before { obj.update(quantity: "0", quantity_unit: "kg") }
      it { expect(subject).to eq("<span title=\"status:zero\" class=\"\"><span class=\"fas fa-ban\"></span></span>") }
    end
    context "disposal" do
      before { obj.record_property.update(disposed: true) }
      it { expect(subject).to eq("<span title=\"status:trash\" class=\"\"><span class=\"far fa-trash-alt\"></span></span>") }
    end
    context "loss" do
      before { obj.record_property.update(lost: true) }
      it { expect(subject).to eq("<span title=\"status:lost\" class=\"\"><span class=\"fas fa-exclamation-triangle\"></span></span>") }
    end
  end
end
