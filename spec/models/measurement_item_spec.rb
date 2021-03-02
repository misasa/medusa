require 'spec_helper'

describe MeasurementItem do

  describe "validates" do
    describe "nickname" do
      let(:obj) { FactoryBot.build(:measurement_item, nickname: nickname) }
      context "is presence" do
        let(:nickname) { "sample_measurement_item" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:nickname) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:nickname) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:nickname) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe ".categorize" do
    subject { MeasurementItem.categorize(measurement_category_id) }
    let(:measurement_category_id) { "123" }
    it { expect(subject.to_sql).to include 'SELECT "measurement_items".* FROM "measurement_items"' }
    it { expect(subject.to_sql).to include 'INNER JOIN "category_measurement_items" ON "category_measurement_items"."measurement_item_id" = "measurement_items"."id"' }
    it { expect(subject.to_sql).to include 'INNER JOIN "measurement_categories" ON "measurement_categories"."id" = "category_measurement_items"."measurement_category_id"' }
    it { expect(subject.to_sql).to include 'WHERE "measurement_categories"."id" = 123' }
  end

  describe ".display_name" do
    subject{obj.display_name}
    let(:obj) { FactoryBot.build(:measurement_item, nickname: nickname,display_in_html: display_in_html) }
    context "display_in_html is not blank" do
      let(:nickname){"nickname"}
      let(:display_in_html){"display_in_html"}
      it {expect(subject).to eq display_in_html}
    end
    context "display_in_html is blank" do
      let(:nickname){"nickname"}
      let(:display_in_html){""}
      it {expect(subject).to eq nickname}
    end
  end

  describe ".tex_name" do
    subject{obj.tex_name}
    let(:obj) { FactoryBot.build(:measurement_item, nickname: nickname,display_in_tex: display_in_tex) }
    context "display_in_tex is not blank" do
      let(:nickname){"nickname"}
      let(:display_in_tex){"display_in_tex"}
      it {expect(subject).to eq display_in_tex}
    end
    context "display_in_tex is blank" do
      let(:nickname){"nickname"}
      let(:display_in_tex){""}
      it {expect(subject).to eq nickname}
    end
  end

end
