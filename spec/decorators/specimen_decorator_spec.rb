require 'spec_helper'
include ActionDispatch::TestProcess

describe SpecimenDecorator do
  let(:user){FactoryGirl.create(:user)}
  let(:obj){FactoryGirl.create(:specimen).decorate}
  let(:box){FactoryGirl.create(:box)}
  before{User.current = user}

  describe "icon" do
    subject { SpecimenDecorator.icon }
    it { expect(subject).to eq ("<span class=\"glyphicon glyphicon-cloud\"></span>") }
  end

  describe "search_name" do
    let(:column) { FactoryGirl.create(:search_column, name: name) }
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
    let(:column) { FactoryGirl.create(:search_column, name: name) }
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
          "<input class=\"form-control input-sm\" id=\"q_name_cont\" name=\"q[name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is igsn" do
      let(:name) { "igsn" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_igsn_cont\" name=\"q[igsn_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is parent" do
      let(:name) { "parent" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_parent_name_cont\" name=\"q[parent_name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is box" do
      let(:name) { "box" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_box_name_cont\" name=\"q[box_name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is physical_form" do
      let(:name) { "physical_form" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_physical_form_name_cont\" name=\"q[physical_form_name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is classification" do
      let(:name) { "classification" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_classification_full_name_cont\" name=\"q[classification_full_name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is tags" do
      let(:name) { "tags" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" id=\"q_tags_name_eq\" name=\"q[tags_name_eq]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
          "<input class=\"form-control input-sm\" id=\"q_user_username_cont\" name=\"q[user_username_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is group" do
      let(:name) { "group" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_group_name_cont\" name=\"q[group_name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is published" do
      let(:name) { "published" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" id=\"q_record_property_published_eq\" name=\"q[record_property_published_eq]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
          + "<option value=\"true\">true</option>\n"\
          + "<option value=\"false\">false</option></select>"
        )
      end
    end
    context "column is published_at" do
      let(:name) { "published_at" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm datepicker\" id=\"q_record_property_published_at_gteq\" name=\"q[record_property_published_at_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"\
          + "<input class=\"form-control input-sm datepicker\" id=\"q_record_property_published_at_lteq_end_of_day\" name=\"q[record_property_published_at_lteq_end_of_day]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
        )
      end
    end
    context "column is updated_at" do
      let(:name) { "updated_at" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm datepicker\" id=\"q_updated_at_gteq\" name=\"q[updated_at_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"\
          + "<input class=\"form-control input-sm datepicker\" id=\"q_updated_at_lteq_end_of_day\" name=\"q[updated_at_lteq_end_of_day]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
        )
      end
    end
    context "column is created_at" do
      let(:name) { "created_at" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm datepicker\" id=\"q_created_at_gteq\" name=\"q[created_at_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"\
          + "<input class=\"form-control input-sm datepicker\" id=\"q_created_at_lteq_end_of_day\" name=\"q[created_at_lteq_end_of_day]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
        )
      end
    end
    context "column is specimen_type" do
      let(:name) { "specimen_type" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_specimen_type_cont\" name=\"q[specimen_type_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is description" do
      let(:name) { "description" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_description_cont\" name=\"q[description_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is place" do
      let(:name) { "place" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_place_name_cont\" name=\"q[place_name_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is quantity" do
      let(:name) { "quantity" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_quantity_gteq\" name=\"q[quantity_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" />"\
          + "<input class=\"form-control input-sm\" id=\"q_quantity_lteq\" name=\"q[quantity_lteq]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is quantity_unit" do
      let(:name) { "quantity_unit" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_quantity_unit_cont\" name=\"q[quantity_unit_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is age_min" do
      let(:name) { "age_min" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_age_min_gteq\" name=\"q[age_min_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" />"\
          + "<input class=\"form-control input-sm\" id=\"q_age_min_lteq\" name=\"q[age_min_lteq]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is age_max" do
      let(:name) { "age_max" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_age_max_gteq\" name=\"q[age_max_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" />"\
          + "<input class=\"form-control input-sm\" id=\"q_age_max_lteq\" name=\"q[age_max_lteq]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is age_unit" do
      let(:name) { "age_unit" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_age_unit_cont\" name=\"q[age_unit_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is size" do
      let(:name) { "size" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_size_cont\" name=\"q[size_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is size_unit" do
      let(:name) { "size_unit" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_size_unit_cont\" name=\"q[size_unit_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is collected_at" do
      let(:name) { "collected_at" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm datepicker\" id=\"q_collected_at_gteq\" name=\"q[collected_at_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"\
          + "<input class=\"form-control input-sm datepicker\" id=\"q_collected_at_lteq_end_of_day\" name=\"q[collected_at_lteq_end_of_day]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
        )
      end
    end
    context "column is collection_date_precision" do
      let(:name) { "collection_date_precision" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_collection_date_precision_cont\" name=\"q[collection_date_precision_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is collector" do
      let(:name) { "collector" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_collector_cont\" name=\"q[collector_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is collector_detail" do
      let(:name) { "collector_detail" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm\" id=\"q_collector_detail_cont\" name=\"q[collector_detail_cont]\" style=\"min-width: 60px;\" type=\"text\" />"
        )
      end
    end
    context "column is disposed" do
      let(:name) { "disposed" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" id=\"q_record_property_disposed_eq\" name=\"q[record_property_disposed_eq]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
          + "<option value=\"true\">true</option>\n"\
          + "<option value=\"false\">false</option></select>"
        )
      end
    end
    context "column is disposed_at" do
      let(:name) { "disposed_at" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm datepicker\" id=\"q_record_property_disposed_at_gteq\" name=\"q[record_property_disposed_at_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"\
          + "<input class=\"form-control input-sm datepicker\" id=\"q_record_property_disposed_at_lteq_end_of_day\" name=\"q[record_property_disposed_at_lteq_end_of_day]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
        )
      end
    end
    context "column is lost" do
      let(:name) { "lost" }
      it do
        expect(subject).to eq(
          "<select class=\"form-control input-sm\" id=\"q_record_property_lost_eq\" name=\"q[record_property_lost_eq]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
          + "<option value=\"true\">true</option>\n"\
          + "<option value=\"false\">false</option></select>"
        )
      end
    end
    context "column is lost_at" do
      let(:name) { "lost_at" }
      it do
        expect(subject).to eq(
          "<input class=\"form-control input-sm datepicker\" id=\"q_record_property_lost_at_gteq\" name=\"q[record_property_lost_at_gteq]\" placeholder=\"from:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"\
          + "<input class=\"form-control input-sm datepicker\" id=\"q_record_property_lost_at_lteq_end_of_day\" name=\"q[record_property_lost_at_lteq_end_of_day]\" placeholder=\"to:\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
        )
      end
    end
  end

  describe "create_form" do
    let(:column) { FactoryGirl.create(:search_column, name: name) }
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
            "<input class=\"form-control input-sm\" id=\"specimen_name\" name=\"specimen[name]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            + "<input class=\"form-control input-sm\" id=\"specimen_parent_global_id\" name=\"specimen[parent_global_id]\" style=\"min-width: 60px;\" type=\"text\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-input=\"#specimen_parent_global_id\" data-target=\"#search-modal\" data-toggle=\"modal\" href=\"/specimens.modal?per_page=10\">"\
            + "<span class=\"glyphicon glyphicon-search\"></span>"\
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
            + "<input class=\"form-control input-sm\" id=\"specimen_parent_global_id\" name=\"specimen[parent_global_id]\" style=\"min-width: 60px;\" type=\"text\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-input=\"#specimen_parent_global_id\" data-target=\"#search-modal\" data-toggle=\"modal\" href=\"/specimens.modal?per_page=10\">"\
            + "<span class=\"glyphicon glyphicon-search\"></span>"\
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
            + "<input class=\"form-control input-sm\" id=\"specimen_box_global_id\" name=\"specimen[box_global_id]\" style=\"min-width: 60px;\" type=\"text\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-input=\"#specimen_box_global_id\" data-target=\"#search-modal\" data-toggle=\"modal\" href=\"/boxes.modal?per_page=10\">"\
            + "<span class=\"glyphicon glyphicon-search\"></span>"\
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
            + "<input class=\"form-control input-sm\" id=\"specimen_box_global_id\" name=\"specimen[box_global_id]\" style=\"min-width: 60px;\" type=\"text\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-input=\"#specimen_box_global_id\" data-target=\"#search-modal\" data-toggle=\"modal\" href=\"/boxes.modal?per_page=10\">"\
            + "<span class=\"glyphicon glyphicon-search\"></span>"\
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
            "<select class=\"form-control input-sm\" id=\"specimen_physical_form_id\" name=\"specimen[physical_form_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
            + "</select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" id=\"specimen_physical_form_id\" name=\"specimen[physical_form_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<select class=\"form-control input-sm\" id=\"specimen_classification_id\" name=\"specimen[classification_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
            + "</select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" id=\"specimen_classification_id\" name=\"specimen[classification_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<input class=\"form-control input-sm\" id=\"specimen_tag_list\" name=\"specimen[tag_list]\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_tag_list\" name=\"specimen[tag_list]\" style=\"min-width: 60px;\" type=\"text\" value=\"\" />"
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
            "<select class=\"form-control input-sm\" id=\"specimen_user_id\" name=\"specimen[user_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<select class=\"form-control input-sm\" id=\"specimen_group_id\" name=\"specimen[group_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
            + "</select>"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<select class=\"form-control input-sm\" id=\"specimen_group_id\" name=\"specimen[group_id]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<select class=\"form-control input-sm\" id=\"specimen_published\" name=\"specimen[published]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<input class=\"form-control input-sm\" id=\"specimen_specimen_type\" name=\"specimen[specimen_type]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_specimen_type\" name=\"specimen[specimen_type]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_description\" name=\"specimen[description]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_description\" name=\"specimen[description]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            + "<input class=\"form-control input-sm\" id=\"specimen_place_global_id\" name=\"specimen[place_global_id]\" style=\"min-width: 60px;\" type=\"text\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-input=\"#specimen_place_global_id\" data-target=\"#search-modal\" data-toggle=\"modal\" href=\"/places.modal?per_page=10\">"\
            + "<span class=\"glyphicon glyphicon-search\"></span>"\
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
            + "<input class=\"form-control input-sm\" id=\"specimen_place_global_id\" name=\"specimen[place_global_id]\" style=\"min-width: 60px;\" type=\"text\" />"\
            + "<span class=\"input-group-addon\">"\
            + "<a data-input=\"#specimen_place_global_id\" data-target=\"#search-modal\" data-toggle=\"modal\" href=\"/places.modal?per_page=10\">"\
            + "<span class=\"glyphicon glyphicon-search\"></span>"\
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
            "<input class=\"form-control input-sm\" id=\"specimen_quantity\" name=\"specimen[quantity]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_quantity\" name=\"specimen[quantity]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_quantity_unit\" name=\"specimen[quantity_unit]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_quantity_unit\" name=\"specimen[quantity_unit]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_age_min\" name=\"specimen[age_min]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_age_min\" name=\"specimen[age_min]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_age_max\" name=\"specimen[age_max]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_age_max\" name=\"specimen[age_max]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<select class=\"form-control input-sm\" id=\"specimen_age_unit\" name=\"specimen[age_unit]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<select class=\"form-control input-sm\" id=\"specimen_age_unit\" name=\"specimen[age_unit]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<input class=\"form-control input-sm\" id=\"specimen_size\" name=\"specimen[size]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_size\" name=\"specimen[size]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_size_unit\" name=\"specimen[size_unit]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_size_unit\" name=\"specimen[size_unit]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_collected_at\" name=\"specimen[collected_at]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_collected_at\" name=\"specimen[collected_at]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_collection_date_precision\" name=\"specimen[collection_date_precision]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_collection_date_precision\" name=\"specimen[collection_date_precision]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_collector\" name=\"specimen[collector]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_collector\" name=\"specimen[collector]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<input class=\"form-control input-sm\" id=\"specimen_collector_detail\" name=\"specimen[collector_detail]\" style=\"min-width: 60px;\" type=\"text\" />"
          )
        end
      end
      context "bundle_edit" do
        let(:page_type) { :bundle_edit }
        it do
          expect(subject).to eq(
            "<input class=\"form-control input-sm\" id=\"specimen_collector_detail\" name=\"specimen[collector_detail]\" style=\"min-width: 60px;\" type=\"text\" />"
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
            "<select class=\"form-control input-sm\" id=\"specimen_disposed\" name=\"specimen[disposed]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
            "<select class=\"form-control input-sm\" id=\"specimen_lost\" name=\"specimen[lost]\" style=\"min-width: 60px;\"><option value=\"\"></option>\n"\
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
    let(:parent) { FactoryGirl.create(:specimen, name: "parent1") }
    let(:box) { FactoryGirl.create(:box, name: "box1") }
    let(:place) { FactoryGirl.create(:place, name: "place1") }
    let(:physical_form) { FactoryGirl.create(:physical_form, name: "physical_form1") }
    let(:parent_classification) { FactoryGirl.create(:classification, name: "classification1") }
    let(:classification) { FactoryGirl.create(:classification, name: "classification2", parent: parent_classification) }
    let(:group) { FactoryGirl.create(:group, name: "group1") }
    let(:time) { "2016-11-01 10:11:12".to_time }
    let(:specimen) do
      FactoryGirl.create(:specimen,
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
      specimen.save!
    end
    subject { specimen.decorate.content(column_name) }
    describe "name_link" do
      let(:column_name){ "name" }
      it do
        expect(subject).to eq(
          "<a class=\" ghost\" href=\"/specimens/#{specimen.id}\">specimen1</a>"
        )
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
    let(:analysis_1){FactoryGirl.create(:analysis)}
    let(:item_1){FactoryGirl.create(:measurement_item)}
    let(:chemistry_1){FactoryGirl.create(:chemistry, :analysis_id => analysis_1.id, :measurement_item_id => item_1.id)}
    before {
      allow(obj.h).to receive(:can?).and_return(true)
      analysis_1.specimen = obj
      analysis_1.save
    }

    it { expect(subject).to include("<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#specimen-analyses-#{obj.id}\"><span class=\"badge\">1</span></a>") }
  end

  describe ".name_with_id" do
    subject{obj.name_with_id}
    it{expect(subject).to include(obj.name)}
    it{expect(subject).to include(obj.global_id)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span>")} 
  end

  describe ".path" do
    let(:me){"<span class=\"\"><span class=\"glyphicon glyphicon-cloud\"></span><span class=\"glyphicon glyphicon-\"></span></span>#{obj.name}"}
    subject{obj.path}
    before { allow(obj.h).to receive(:can?).and_return(true) }
    context "box is nil" do
      before{obj.box = nil}
      it{expect(subject).to eq me} 
    end
    context "box is not nil" do
      before{obj.box = box}
      it{expect(subject).to include("<span class=\"glyphicon glyphicon-folder-close\"></span>")} 
      it{expect(subject).to include("<a href=\"/boxes/#{box.id}\">#{box.name}</a>")} 
      it{expect(subject).to include(me)} 
    end
  end

  describe ".primary_picture" do
    let(:attachment_file){ FactoryGirl.create(:attachment_file) }
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
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span>")}
    it{expect(subject).to match("<a href=\"/specimens/#{obj.id}\">.*</a>")}
    it{expect(subject).to include("<strong class=\"text-primary bg-primary\">#{obj.name}</strong>")} 
  end

  describe "tree_nodes" do
    let(:specimen) { FactoryGirl.create(:specimen, name: "test_1") }
    let(:analysis) { FactoryGirl.create(:analysis, name: "test_2") }
    let(:bib) { FactoryGirl.create(:bib, name: "test_3") }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, name: "test_4", data_file_name: "test_4.jpg") }
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
          + "<span class=\"glyphicon glyphicon-stats\"></span>"\
          + "<a href=\"/analyses/#{analysis.id}\">test_2</a>"\
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
          + "<span class=\"glyphicon glyphicon-book\"></span>"\
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
          + "<span class=\"glyphicon glyphicon-file\"></span>"\
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
    let(:child){FactoryGirl.create(:specimen)}
    let(:analysis){FactoryGirl.create(:analysis)}
    let(:bib){FactoryGirl.create(:bib)}
    let(:attachment_file){FactoryGirl.create(:attachment_file)}
    it{expect(subject).to include("<span class=\"glyphicon glyphicon-cloud\"></span>")} 
    it{expect(subject).to include("#{obj.name}")} 
    before do
      obj.children << child
      obj.analyses << analysis
      obj.bibs << bib 
      obj.attachment_files << attachment_file 
    end
    it { expect(subject).to_not include("<span class=\"glyphicon glyphicon-cloud \"></span><span>#{obj.children.count}</span>") }
    it do
      expect(subject).to include(
        "<span class=\"\"><span class=\"glyphicon glyphicon-stats\"></span></span>"\
        + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Analysis-#{obj.record_property_id}\">"\
        + "<span class=\"badge\" data-klass=\"Analysis\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.analyses.count}</span></a>"
      )
    end
    it do
      expect(subject).to include(
        "<span class=\"\"><span class=\"glyphicon glyphicon-book\"></span></span>"\
        + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Bib-#{obj.record_property_id}\">"\
        + "<span class=\"badge\" data-klass=\"Bib\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.bibs.count}</span></a>"
      )
    end
    it do
      expect(subject).to include(
        "<span class=\"\"><span class=\"glyphicon glyphicon-file\"></span></span>"\
        + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-AttachmentFile-#{obj.record_property_id}\">"\
        + "<span class=\"badge\" data-klass=\"AttachmentFile\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.attachment_files.count}</span></a>"
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
            "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-cloud\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Specimen-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\" data-klass=\"Specimen\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.children.count}</span></a>"
          )
        end
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-stats\"></span><span>#{obj.analyses.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-book\"></span><span>#{obj.bibs.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-file\"></span><span>#{obj.attachment_files.count}</span>") }
      end
      context "not in_list_include" do
        subject{ obj.tree_node(current_type: true, in_list_include: false) }
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"glyphicon glyphicon-cloud\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Specimen-#{obj.record_property_id}\">"\
            + "<span class=\"badge\" data-klass=\"Specimen\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.children.count}</span></a>"
          )
        end
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-stats\"></span><span>#{obj.analyses.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-book\"></span><span>#{obj.bibs.count}</span>") }
        it { expect(subject).to include("<span class=\"glyphicon glyphicon-file\"></span><span>#{obj.attachment_files.count}</span>") }
      end
    end
    context "not current_type" do
      context "in_list_include" do
        subject{ obj.tree_node(current_type: false, in_list_include: true) }
        it{ expect(subject).to_not include("<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.children.count}</span>") }
        it do
          expect(subject).to include(
            "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-stats\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Analysis-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\" data-klass=\"Analysis\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.analyses.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-book\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Bib-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\" data-klass=\"Bib\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.bibs.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-file\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-AttachmentFile-#{obj.record_property_id}\">"\
            + "<span class=\"badge badge-active\" data-klass=\"AttachmentFile\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.attachment_files.count}</span></a>"
          )
        end
      end
      context "not in_list_include" do
        subject{ obj.tree_node(current_type: false, in_list_include: false) }
        it{ expect(subject).to_not include("<span class=\"glyphicon glyphicon-cloud\"></span><span>#{obj.children.count}</span>") }
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"glyphicon glyphicon-stats\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Analysis-#{obj.record_property_id}\">"\
            + "<span class=\"badge\" data-klass=\"Analysis\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.analyses.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"glyphicon glyphicon-book\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-Bib-#{obj.record_property_id}\">"\
            + "<span class=\"badge\" data-klass=\"Bib\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.bibs.count}</span></a>"
          )
        end
        it do
          expect(subject).to include(
            "<span class=\"\"><span class=\"glyphicon glyphicon-file\"></span></span>"\
            + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-AttachmentFile-#{obj.record_property_id}\">"\
            + "<span class=\"badge\" data-klass=\"AttachmentFile\" data-record_property_id=\"#{obj.record_property_id}\">#{obj.attachment_files.count}</span></a>"
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
    let(:child) { FactoryGirl.create(:specimen) }
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
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.children_count(true, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
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
    let(:analysis) { FactoryGirl.create(:analysis) }
    context "count zero" do
      before { obj.analyses.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.analyses << analysis }
      context "current_type" do
        context "in_list_include" do
          subject { obj.analyses_count(true, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.analyses_count(true, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.analyses_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.analyses_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
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
    let(:bib) { FactoryGirl.create(:bib) }
    context "count zero" do
      before { obj.bibs.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.bibs << bib }
      context "current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(true, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.bibs_count(true, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.bibs_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.bibs_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
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
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    context "count zero" do
      before { obj.attachment_files.clear }
      it { expect(subject).to be_blank }
    end
    context "count not zero" do
      before { obj.attachment_files << attachment_file }
      context "current_type" do
        context "in_list_include" do
          subject { obj.files_count(true, true) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
        context "not in_list_include" do
          subject { obj.files_count(true, false) }
          it { expect(subject).to eq("<span class=\"glyphicon glyphicon-#{icon}\"></span><span>#{count}</span>") }
        end
      end
      context "not current_type" do
        context "in_list_include" do
          subject { obj.files_count(false, true) }
          it do
            expect(subject).to eq(
              "<span class=\"glyphicon-active-color\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge badge-active\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
            )
          end
        end
        context "not in_list_include" do
          subject { obj.files_count(false, false) }
          it do
            expect(subject).to eq(
              "<span class=\"\"><span class=\"glyphicon glyphicon-#{icon}\"></span></span>"\
              + "<a class=\"collapse-active\" data-toggle=\"collapse\" href=\"#tree-#{klass}-#{obj.record_property_id}\">"\
              + "<span class=\"badge\" data-klass=\"#{klass}\" data-record_property_id=\"#{obj.record_property_id}\">#{count}</span></a>"
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
    let(:child) { FactoryGirl.create(:specimen, name: child_name) }
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
      before { obj.update_attributes(quantity: 0.5, quantity_unit: "mg") }
      it { expect(subject).to eq("") }
    end
    context "undetermined quantity" do
      before { obj.update_attributes(quantity: "", quantity_unit: "") }
      it { expect(subject).to eq("unknown") }
    end
    context "disappearance" do
      before { obj.update_attributes(quantity: "0", quantity_unit: "kg") }
      it { expect(subject).to eq("zero") }
    end
    context "disposal" do
      before { obj.record_property.update_attributes(disposed: true) }
      it { expect(subject).to eq("trash") }
    end
    context "loss" do
      before { obj.record_property.update_attributes(lost: true) }
      it { expect(subject).to eq("lost") }
    end
  end

  describe "status_icon" do
    subject { obj.status_icon }
    context "normal" do
      before { obj.update_attributes(quantity: 0.5, quantity_unit: "mg") }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-\" title=\"status:\"></span>") }
    end
    context "undetermined quantity" do
      before { obj.update_attributes(quantity: "", quantity_unit: "") }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-question-sign\" title=\"status:unknown\"></span>") }
    end
    context "disappearance" do
      before { obj.update_attributes(quantity: "0", quantity_unit: "kg") }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-ban-circle\" title=\"status:zero\"></span>") }
    end
    context "disposal" do
      before { obj.record_property.update_attributes(disposed: true) }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-trash\" title=\"status:trash\"></span>") }
    end
    context "loss" do
      before { obj.record_property.update_attributes(lost: true) }
      it { expect(subject).to eq("<span class=\"glyphicon glyphicon-warning-sign\" title=\"status:lost\"></span>") }
    end
  end


end
