require "spec_helper"

describe "Table" do
  let(:table) { FactoryGirl.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryGirl.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryGirl.create(:unit) }
  let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit) }
  pending
end

